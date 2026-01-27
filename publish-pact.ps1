<#
.SYNOPSIS
    Run consumer tests and publish the generated contract to PactFlow.

.DESCRIPTION
    This script performs three steps:
    1. Runs consumer Pact tests to generate a contract file
    2. Validates the contract file was created successfully
    3. Publishes the contract to PactFlow broker with version and branch metadata
    
    The contract defines what messages this consumer expects from its provider.
    Publishing allows the provider to verify they can meet these expectations.

.PARAMETER BrokerBaseUrl
    PactFlow broker URL (default: https://dom-crosbie.pactflow.io)

.PARAMETER BrokerToken
    PactFlow authentication token (default: uses stored token)

.PARAMETER ConsumerVersion
    Semantic version for this consumer release (default: 1.0.0)

.PARAMETER Branch
    Git branch name for versioning and can-i-deploy checks (default: main)

.PARAMETER Tag
    Optional tag to apply to this version (e.g., 'prod', 'staging', 'new-feature')

.EXAMPLE
    .\publish-pact.ps1
    Publish with default settings (version 1.0.0, branch main)

.EXAMPLE
    .\publish-pact.ps1 -ConsumerVersion "1.2.3" -Branch "feature/new-api"
    Publish a specific version from a feature branch

.EXAMPLE
    .\publish-pact.ps1 -ConsumerVersion "2.0.0" -Branch "main" -Tag "prod"
    Publish and tag as production version

.EXAMPLE
    .\publish-pact.ps1 -ConsumerVersion "1.5.0" -Tag "new-feature"
    Publish with a tag for demo purposes

.ALTERNATIVE COMMAND LINE CALLS
    Using pact-broker CLI directly:
    
    # First run tests to generate contract
    cd tests
    dotnet test
    cd ..

    # Then publish
    pact-broker publish tests/pacts/EventDrivenConsumer-EventDrivenProvider.json \
      --consumer-app-version=1.0.0 \
      --branch=main \
      --broker-base-url=https://dom-crosbie.pactflow.io \
      --broker-token=YOUR_TOKEN

    # With a tag
    pact-broker publish tests/pacts/EventDrivenConsumer-EventDrivenProvider.json \
      --consumer-app-version=1.0.0 \
      --branch=main \
      --tag=new-feature \
      --broker-base-url=https://dom-crosbie.pactflow.io \
      --broker-token=YOUR_TOKEN

    Using Docker:
    
    docker run --rm -v "${PWD}/tests/pacts:/pacts" pactfoundation/pact-cli:latest \
      publish /pacts/EventDrivenConsumer-EventDrivenProvider.json \
      --consumer-app-version=1.0.0 \
      --branch=main \
      --broker-base-url=https://dom-crosbie.pactflow.io \
      --broker-token=YOUR_TOKEN

.NOTES
    Exit Codes:
    - 0: Success (tests passed and contract published)
    - 1: Failure (tests failed, contract not found, or publish failed)
#>

param(
    [string]$BrokerBaseUrl = "https://dom-crosbie.pactflow.io",
    [string]$BrokerToken = "T1oRYTFhcDphYPMB1gkpNw",
    [string]$ConsumerVersion = "1.0.0",
    [string]$Branch = "main",
    [string]$Tag = ""
)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Publishing Pact Contract to PactFlow" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# Step 1: Run consumer tests to generate the pact file
Write-Host "`n[Step 1/3] Running consumer tests..." -ForegroundColor Yellow
Set-Location $PSScriptRoot\tests
dotnet test

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ Consumer tests failed! Cannot publish invalid contract." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Consumer tests passed!" -ForegroundColor Green

# Step 2: Find the generated pact file
$pactFile = Get-ChildItem -Path "pacts\EventDrivenConsumer-EventDrivenProvider.json" -ErrorAction SilentlyContinue

if (-not $pactFile) {
    Write-Host "`n❌ Pact file not found! Expected: pacts\EventDrivenConsumer-EventDrivenProvider.json" -ForegroundColor Red
    exit 1
}

Write-Host "`n✅ Found pact file: $($pactFile.FullName)" -ForegroundColor Green

# Step 3: Check for publishing method
Write-Host "`n[Step 2/3] Checking for pact-broker CLI..." -ForegroundColor Yellow

$pactBrokerCli = Get-Command pact-broker -ErrorAction SilentlyContinue
$useDocker = $false

if (-not $pactBrokerCli) {
    Write-Host "⚠️  pact-broker CLI not found. Will use Docker instead..." -ForegroundColor Yellow
    $useDocker = $true
} else {
    Write-Host "✅ pact-broker CLI already installed!" -ForegroundColor Green
}

# Step 4: Publish to PactFlow
Write-Host "`n[Step 3/3] Publishing to PactFlow broker..." -ForegroundColor Yellow
Write-Host "Broker URL: $BrokerBaseUrl" -ForegroundColor Gray
Write-Host "Consumer: EventDrivenConsumer" -ForegroundColor Gray
Write-Host "Version: $ConsumerVersion" -ForegroundColor Gray
Write-Host "Branch: $Branch" -ForegroundColor Gray

if ($useDocker) {
    # Use Docker method
    Write-Host "Using Docker to publish..." -ForegroundColor Yellow
    
    $pactDir = Split-Path $pactFile.FullName -Parent
    $pactFileName = Split-Path $pactFile.FullName -Leaf
    
    docker run --rm -v "${pactDir}:/pacts" pactfoundation/pact-cli:latest `
        publish `
        "/pacts/$pactFileName" `
        --consumer-app-version=$ConsumerVersion `
        --branch=$Branch `
        --broker-base-url=$BrokerBaseUrl `
        --broker-token=$BrokerToken
} else {
    # Use pact-broker CLI
    $publishArgs = @(
        "publish",
        $pactFile.FullName,
        "--consumer-app-version=$ConsumerVersion",
        "--branch=$Branch",
        "--broker-base-url=$BrokerBaseUrl",
        "--broker-token=$BrokerToken"
    )
    
    if ($Tag) {
        $publishArgs += "--tag=$Tag"
    }
    
    pact-broker @publishArgs
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Successfully published contract to PactFlow!" -ForegroundColor Green
    Write-Host "View at: $BrokerBaseUrl" -ForegroundColor Cyan
} else {
    Write-Host "`n❌ Failed to publish contract to PactFlow" -ForegroundColor Red
    exit 1
}

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "✨ Consumer workflow complete!" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
