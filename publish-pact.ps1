# Publish Consumer Pact to PactFlow Broker
# This script runs the consumer tests and publishes the generated contract to PactFlow

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
