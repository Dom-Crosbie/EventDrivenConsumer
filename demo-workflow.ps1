<#
.SYNOPSIS
    Interactive demo script for Contract Testing workflow with can-i-deploy checks.

.DESCRIPTION
    This script walks through a complete contract testing demo:
    1. Publish current contract with 'new-feature' tag
    2. Run can-i-deploy check (expect success if provider has verified)
    3. Guide you through making a breaking change
    4. Run can-i-deploy check again (expect failure)
    
    This demonstrates how contract testing prevents breaking changes from reaching production.

.EXAMPLE
    .\demo-workflow.ps1
    Run the interactive demo

.NOTES
    This script is for demonstration and learning purposes.
#>

param(
    [string]$BrokerBaseUrl = "https://dom-crosbie.pactflow.io",
    [string]$BrokerToken = "T1oRYTFhcDphYPMB1gkpNw"
)

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Contract Testing Demo Workflow" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

Write-Host "`n📋 Demo Overview:" -ForegroundColor White
Write-Host "  1. Publish contract with 'new-feature' tag" -ForegroundColor Gray
Write-Host "  2. Check if safe to deploy (should pass)" -ForegroundColor Gray
Write-Host "  3. Make breaking change to consumer" -ForegroundColor Gray
Write-Host "  4. Check if safe to deploy (should fail)" -ForegroundColor Gray

Write-Host "`n" -ForegroundColor White
Read-Host "Press Enter to start the demo"

# Step 1: Publish current contract
Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "STEP 1: Publishing Current Contract" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

Write-Host "`nThis will run your tests and publish the contract with tag 'new-feature'" -ForegroundColor Yellow

.\publish-pact.ps1 -ConsumerVersion "1.0.0" -Branch "main" -Tag "new-feature" `
    -BrokerBaseUrl $BrokerBaseUrl -BrokerToken $BrokerToken

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ Failed to publish contract. Please fix test errors first." -ForegroundColor Red
    exit 1
}

Write-Host "`n✅ Contract published with tag 'new-feature'" -ForegroundColor Green
Start-Sleep -Seconds 2

# Step 2: First can-i-deploy check
Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "STEP 2: Can I Deploy Check (Should Pass)" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

Write-Host "`nChecking if version 1.0.0 can be safely deployed..." -ForegroundColor Yellow
Start-Sleep -Seconds 1

.\can-i-deploy.ps1 -ConsumerVersion "1.0.0" -Environment "production" `
    -BrokerBaseUrl $BrokerBaseUrl -BrokerToken $BrokerToken

$firstCheckResult = $LASTEXITCODE

if ($firstCheckResult -eq 0) {
    Write-Host "`n✅ As expected: Safe to deploy!" -ForegroundColor Green
    Write-Host "   The provider has verified this contract version." -ForegroundColor Gray
} else {
    Write-Host "`n⚠️  Unexpected: Not safe to deploy" -ForegroundColor Yellow
    Write-Host "   This might mean:" -ForegroundColor Gray
    Write-Host "   - The provider hasn't verified this contract yet" -ForegroundColor Gray
    Write-Host "   - The provider verification failed" -ForegroundColor Gray
    Write-Host "`n   Check your PactFlow dashboard: $BrokerBaseUrl" -ForegroundColor Cyan
}

Write-Host "`n" -ForegroundColor White
Read-Host "Press Enter to continue to the breaking change demo"

# Step 3: Guide for breaking change
Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "STEP 3: Make a Breaking Change" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

Write-Host "`n📝 Instructions:" -ForegroundColor White
Write-Host "   1. Open: tests/ConsumerEventTests.cs" -ForegroundColor Yellow
Write-Host "   2. Find the line with: @event = Match.Regex(..." -ForegroundColor Yellow
Write-Host "   3. Change 'UPDATED' to 'ARCHIVED'" -ForegroundColor Yellow
Write-Host "      Before: @event = Match.Regex(`"UPDATED`", `"^(CREATED|UPDATED|DELETED)$`")" -ForegroundColor Gray
Write-Host "      After:  @event = Match.Regex(`"ARCHIVED`", `"^(CREATED|UPDATED|DELETED|ARCHIVED)$`")" -ForegroundColor Gray
Write-Host "`n   This simulates adding a new event type that the provider doesn't support yet." -ForegroundColor White

Write-Host "`n" -ForegroundColor White
Read-Host "Make the change above, then press Enter to continue"

# Step 4: Publish breaking change
Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "STEP 4: Publishing Breaking Change" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

Write-Host "`nPublishing new contract version 1.1.0 with breaking change..." -ForegroundColor Yellow

.\publish-pact.ps1 -ConsumerVersion "1.1.0" -Branch "main" -Tag "new-feature" `
    -BrokerBaseUrl $BrokerBaseUrl -BrokerToken $BrokerToken

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ Failed to publish contract. Check test errors." -ForegroundColor Red
    exit 1
}

Write-Host "`n✅ Breaking change published as version 1.1.0" -ForegroundColor Green
Start-Sleep -Seconds 2

# Step 5: Second can-i-deploy check
Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "STEP 5: Can I Deploy Check (Should Fail)" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

Write-Host "`nChecking if version 1.1.0 can be safely deployed..." -ForegroundColor Yellow
Write-Host "Expected result: ❌ NOT safe to deploy" -ForegroundColor Yellow
Start-Sleep -Seconds 1

.\can-i-deploy.ps1 -ConsumerVersion "1.1.0" -Environment "production" `
    -BrokerBaseUrl $BrokerBaseUrl -BrokerToken $BrokerToken

$secondCheckResult = $LASTEXITCODE

Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "Demo Complete!" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

Write-Host "`n📊 Results Summary:" -ForegroundColor White
Write-Host "   Version 1.0.0 can-i-deploy: $(if ($firstCheckResult -eq 0) { '✅ PASS' } else { '❌ FAIL' })" -ForegroundColor $(if ($firstCheckResult -eq 0) { 'Green' } else { 'Red' })
Write-Host "   Version 1.1.0 can-i-deploy: $(if ($secondCheckResult -eq 0) { '✅ PASS (unexpected)' } else { '❌ FAIL (expected)' })" -ForegroundColor $(if ($secondCheckResult -eq 0) { 'Yellow' } else { 'Green' })

Write-Host "`n🎓 What You Learned:" -ForegroundColor White
Write-Host "   ✅ can-i-deploy prevents deploying breaking changes" -ForegroundColor Gray
Write-Host "   ✅ Contract testing catches incompatibilities before production" -ForegroundColor Gray
Write-Host "   ✅ Providers must verify new consumer expectations first" -ForegroundColor Gray

Write-Host "`n🔍 Next Steps:" -ForegroundColor White
Write-Host "   1. Check PactFlow dashboard: $BrokerBaseUrl" -ForegroundColor Cyan
Write-Host "   2. See the matrix showing version 1.1.0 is not verified" -ForegroundColor Gray
Write-Host "   3. Provider would need to verify the new contract before you can deploy" -ForegroundColor Gray

Write-Host "`n💡 To Reset:" -ForegroundColor White
Write-Host "   Revert the change in ConsumerEventTests.cs back to 'UPDATED'" -ForegroundColor Gray

Write-Host "`n" -ForegroundColor White
