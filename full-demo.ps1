<#
.SYNOPSIS
    Complete end-to-end demo showing Contract Testing catching breaking changes.

.DESCRIPTION
    This demo shows:
    1. Consumer application processing Kafka events
    2. Publishing a working contract
    3. Making a breaking change to consumer expectations
    4. Contract testing preventing deployment of the breaking change
    
    Prerequisites: Docker running with Kafka

.EXAMPLE
    .\full-demo.ps1
#>

param(
    [string]$BrokerBaseUrl = "https://dom-crosbie.pactflow.io",
    [string]$BrokerToken = "T1oRYTFhcDphYPMB1gkpNw"
)

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Contract Testing Full Demo" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# Step 1: Verify Kafka is running
Write-Host "`n[Step 1/8] Checking Kafka infrastructure..." -ForegroundColor Yellow

$kafkaRunning = docker ps --filter "name=demo-kafka" --format "{{.Names}}"
if (-not $kafkaRunning) {
    Write-Host "❌ Kafka not running. Starting Kafka..." -ForegroundColor Red
    .\start-kafka.ps1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to start Kafka. Exiting." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ Kafka is running" -ForegroundColor Green
}

Start-Sleep -Seconds 2

# Step 2: Start consumer application
Write-Host "`n[Step 2/8] Starting consumer application..." -ForegroundColor Yellow
Write-Host "Starting on http://localhost:5001" -ForegroundColor Gray

$consumerJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    cd src
    dotnet run
}

Write-Host "⏳ Waiting for consumer to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Check if it's running
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5001/products" -ErrorAction SilentlyContinue -TimeoutSec 5
    Write-Host "✅ Consumer application is running" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Consumer may not be fully started yet" -ForegroundColor Yellow
}

# Step 3: Send initial events
Write-Host "`n[Step 3/8] Sending test events to Kafka..." -ForegroundColor Yellow

.\send-event.ps1 -Mode quick

Start-Sleep -Seconds 2

# Step 4: Verify events were processed
Write-Host "`n[Step 4/8] Verifying events were processed..." -ForegroundColor Yellow

try {
    $events = Invoke-RestMethod -Uri "http://localhost:5001/api/events" -Method Get
    Write-Host "✅ Consumer processed $($events.Count) events:" -ForegroundColor Green
    $events | ForEach-Object {
        Write-Host "  - $($_.name) (ID: $($_.id), Type: $($_.type))" -ForegroundColor Gray
    }
} catch {
    Write-Host "⚠️  Could not verify events at /api/events endpoint" -ForegroundColor Yellow
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Gray
}

Write-Host "`n" -ForegroundColor White
Read-Host "Press Enter to continue to contract testing demo"

# Step 5: Publish working contract (version 1.0.0)
Write-Host "`n[Step 5/8] Publishing working contract (v1.0.0)..." -ForegroundColor Yellow

.\publish-pact.ps1 -ConsumerVersion "1.0.0" -Branch "main" -Tag "demo" `
    -BrokerBaseUrl $BrokerBaseUrl -BrokerToken $BrokerToken

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to publish contract. Check output above." -ForegroundColor Red
    Stop-Job $consumerJob
    Remove-Job $consumerJob
    exit 1
}

Write-Host "✅ Contract v1.0.0 published" -ForegroundColor Green
Start-Sleep -Seconds 2

# Step 6: Check can-i-deploy for v1.0.0 (should pass if provider verified)
Write-Host "`n[Step 6/8] Checking if v1.0.0 can be deployed..." -ForegroundColor Yellow

.\can-i-deploy.ps1 -ConsumerVersion "1.0.0" `
    -BrokerBaseUrl $BrokerBaseUrl -BrokerToken $BrokerToken

$v1CanDeploy = $LASTEXITCODE

Write-Host "`n" -ForegroundColor White
Read-Host "Press Enter to make a breaking change"

# Step 7: Guide user to make breaking change
Write-Host "`n[Step 7/8] BREAKING CHANGE TIME!" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

Write-Host "`n📝 Instructions - Make this change NOW:" -ForegroundColor White
Write-Host "`nFile: tests/ConsumerEventTests.cs" -ForegroundColor Yellow
Write-Host "Find line ~31:" -ForegroundColor Gray
Write-Host '  @event = Match.Regex("UPDATED", "^(CREATED|UPDATED|DELETED)$")' -ForegroundColor DarkGray
Write-Host "`nChange to:" -ForegroundColor Gray
Write-Host '  @event = Match.Regex("ARCHIVED", "^(CREATED|UPDATED|DELETED|ARCHIVED)$")' -ForegroundColor Green

Write-Host "`n💡 This simulates consumer adding a new event type requirement" -ForegroundColor White
Write-Host "   that the provider doesn't support yet." -ForegroundColor Gray

Write-Host "`n" -ForegroundColor White
Read-Host "After making the change, press Enter to continue"

# Step 8: Publish breaking change (version 1.1.0)
Write-Host "`n[Step 8/8] Publishing breaking change (v1.1.0)..." -ForegroundColor Yellow

.\publish-pact.ps1 -ConsumerVersion "1.1.0" -Branch "main" -Tag "demo" `
    -BrokerBaseUrl $BrokerBaseUrl -BrokerToken $BrokerToken

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to publish contract. Check the change was made correctly." -ForegroundColor Red
    Stop-Job $consumerJob
    Remove-Job $consumerJob
    exit 1
}

Write-Host "✅ Contract v1.1.0 published" -ForegroundColor Green
Start-Sleep -Seconds 2

# Step 9: Check can-i-deploy for v1.1.0 (should fail - breaking change!)
Write-Host "`n[Step 9/8] Checking if v1.1.0 can be deployed..." -ForegroundColor Yellow
Write-Host "Expected: ❌ FAIL (provider hasn't verified new contract)" -ForegroundColor Yellow

.\can-i-deploy.ps1 -ConsumerVersion "1.1.0" `
    -BrokerBaseUrl $BrokerBaseUrl -BrokerToken $BrokerToken

$v2CanDeploy = $LASTEXITCODE

# Cleanup
Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "  Demo Complete! Cleaning up..." -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

Stop-Job $consumerJob -ErrorAction SilentlyContinue
Remove-Job $consumerJob -ErrorAction SilentlyContinue

Write-Host "`n📊 RESULTS SUMMARY" -ForegroundColor White
Write-Host "==================" -ForegroundColor White
Write-Host "Version 1.0.0 deployment: $(if ($v1CanDeploy -eq 0) { '✅ SAFE' } else { '❌ NOT SAFE' })" -ForegroundColor $(if ($v1CanDeploy -eq 0) { 'Green' } else { 'Red' })
Write-Host "Version 1.1.0 deployment: $(if ($v2CanDeploy -eq 0) { '✅ SAFE (unexpected!)' } else { '❌ NOT SAFE (expected!)' })" -ForegroundColor $(if ($v2CanDeploy -eq 0) { 'Yellow' } else { 'Green' })

Write-Host "`n🎓 WHAT YOU LEARNED:" -ForegroundColor White
Write-Host "✅ Consumer processes events from Kafka" -ForegroundColor Gray
Write-Host "✅ Contract tests define consumer expectations" -ForegroundColor Gray
Write-Host "✅ can-i-deploy prevents deploying incompatible changes" -ForegroundColor Gray
Write-Host "✅ Provider must verify new contracts before consumer deploys" -ForegroundColor Gray

Write-Host "`n🔍 NEXT STEPS:" -ForegroundColor White
Write-Host "1. View PactFlow dashboard: $BrokerBaseUrl" -ForegroundColor Cyan
Write-Host "2. See version 1.1.0 is unverified" -ForegroundColor Gray
Write-Host "3. Provider would update code to support ARCHIVED event" -ForegroundColor Gray
Write-Host "4. Provider verifies contract" -ForegroundColor Gray
Write-Host "5. Then v1.1.0 becomes safe to deploy" -ForegroundColor Gray

Write-Host "`n💡 TO RESET:" -ForegroundColor White
Write-Host "Revert the change in ConsumerEventTests.cs" -ForegroundColor Gray

Write-Host ""
