<#
.SYNOPSIS
    Check if this consumer version can be safely deployed to an environment.

.DESCRIPTION
    This script uses the Pact Broker's "can-i-deploy" feature to verify if all
    provider dependencies have been successfully verified against this consumer version.
    
    This prevents breaking changes from being deployed to production by ensuring
    all contracts have been verified before deployment.

.PARAMETER BrokerBaseUrl
    PactFlow broker URL (default: https://dom-crosbie.pactflow.io)

.PARAMETER BrokerToken
    PactFlow authentication token (default: uses stored token)

.PARAMETER ConsumerVersion
    Consumer version to check (default: current git commit SHA)

.PARAMETER Branch
    Git branch to check the latest version from (alternative to ConsumerVersion)

.PARAMETER Environment
    Target environment to check deployment safety (default: production)

.PARAMETER Pacticipant
    Consumer name (default: EventDrivenConsumer)

.EXAMPLE
    .\can-i-deploy.ps1
    Check if the current git commit can be deployed to production

.EXAMPLE
    .\can-i-deploy.ps1 -ConsumerVersion "1.2.0" -Environment "staging"
    Check if version 1.2.0 can be deployed to staging

.EXAMPLE
    .\can-i-deploy.ps1 -Branch "new-feature"
    Check if the latest version on the 'new-feature' branch can be deployed

.ALTERNATIVE COMMAND LINE CALLS
    Using pact-broker CLI directly:
    
    # Check specific version
    pact-broker can-i-deploy \
      --pacticipant EventDrivenConsumer \
      --version 1.2.0 \
      --to-environment production \
      --broker-base-url https://dom-crosbie.pactflow.io \
      --broker-token YOUR_TOKEN

    # Check latest on branch
    pact-broker can-i-deploy \
      --pacticipant EventDrivenConsumer \
      --branch new-feature \
      --to-environment production \
      --broker-base-url https://dom-crosbie.pactflow.io \
      --broker-token YOUR_TOKEN

    Using Docker:
    
    docker run --rm pactfoundation/pact-cli:latest \
      broker can-i-deploy \
      --pacticipant EventDrivenConsumer \
      --version 1.2.0 \
      --to-environment production \
      --broker-base-url https://dom-crosbie.pactflow.io \
      --broker-token YOUR_TOKEN

.NOTES
    Exit Codes:
    - 0: Safe to deploy (all verifications passed)
    - 1: NOT safe to deploy (verifications missing or failed)
#>

param(
    [string]$BrokerBaseUrl = "https://dom-crosbie.pactflow.io",
    [string]$BrokerToken = "T1oRYTFhcDphYPMB1gkpNw",
    [string]$ConsumerVersion = "",
    [string]$Branch = "",
    [string]$Environment = "production",
    [string]$Pacticipant = "EventDrivenConsumer"
)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Can I Deploy Check" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# Determine version to check
if (-not $ConsumerVersion -and -not $Branch) {
    # Default to current git commit
    $ConsumerVersion = git rev-parse --short HEAD
    Write-Host "No version specified, using current git commit: $ConsumerVersion" -ForegroundColor Yellow
}

# Display check parameters
Write-Host "`nCheck Parameters:" -ForegroundColor White
Write-Host "  Pacticipant: $Pacticipant" -ForegroundColor Gray
if ($ConsumerVersion) {
    Write-Host "  Version: $ConsumerVersion" -ForegroundColor Gray
} else {
    Write-Host "  Branch: $Branch (latest version)" -ForegroundColor Gray
}
Write-Host "  Target Environment: $Environment" -ForegroundColor Gray
Write-Host "  Broker: $BrokerBaseUrl" -ForegroundColor Gray

# Check for pact-broker CLI
$pactBrokerCli = Get-Command pact-broker -ErrorAction SilentlyContinue
$useDocker = $false

if (-not $pactBrokerCli) {
    Write-Host "`nℹ️  pact-broker CLI not found. Using Docker..." -ForegroundColor Yellow
    $useDocker = $true
}

Write-Host "`n🔍 Checking deployment safety..." -ForegroundColor Yellow

# Build arguments
if ($useDocker) {
    # Docker method
    if ($ConsumerVersion) {
        docker run --rm pactfoundation/pact-cli:latest `
            broker can-i-deploy `
            --pacticipant=$Pacticipant `
            --version=$ConsumerVersion `
            --to-environment=$Environment `
            --broker-base-url=$BrokerBaseUrl `
            --broker-token=$BrokerToken
    } else {
        docker run --rm pactfoundation/pact-cli:latest `
            broker can-i-deploy `
            --pacticipant=$Pacticipant `
            --branch=$Branch `
            --to-environment=$Environment `
            --broker-base-url=$BrokerBaseUrl `
            --broker-token=$BrokerToken
    }
} else {
    # pact-broker CLI
    if ($ConsumerVersion) {
        pact-broker can-i-deploy `
            --pacticipant=$Pacticipant `
            --version=$ConsumerVersion `
            --to-environment=$Environment `
            --broker-base-url=$BrokerBaseUrl `
            --broker-token=$BrokerToken
    } else {
        pact-broker can-i-deploy `
            --pacticipant=$Pacticipant `
            --branch=$Branch `
            --to-environment=$Environment `
            --broker-base-url=$BrokerBaseUrl `
            --broker-token=$BrokerToken
    }
}

# Check result
if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ SAFE TO DEPLOY!" -ForegroundColor Green
    Write-Host "All provider verifications have passed." -ForegroundColor Green
    Write-Host "`nYou can safely deploy this version to $Environment" -ForegroundColor White
    exit 0
} else {
    Write-Host "`n❌ NOT SAFE TO DEPLOY!" -ForegroundColor Red
    Write-Host "Provider verifications are missing or have failed." -ForegroundColor Red
    Write-Host "`nDo NOT deploy this version to $Environment yet." -ForegroundColor White
    Write-Host "Check the output above for details." -ForegroundColor Yellow
    exit 1
}
