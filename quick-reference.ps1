<#
.SYNOPSIS
    Quick reference guide for common Contract Testing operations.

.DESCRIPTION
    This file documents common commands and workflows for contract testing.
    It's meant as a quick reference and cheat sheet.

#>

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Contract Testing Quick Reference" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

Write-Host "`n📚 COMMON OPERATIONS`n" -ForegroundColor White

Write-Host "1️⃣  Run Consumer Tests" -ForegroundColor Yellow
Write-Host "   cd tests" -ForegroundColor Gray
Write-Host "   dotnet test`n" -ForegroundColor Gray

Write-Host "2️⃣  Publish Contract to PactFlow" -ForegroundColor Yellow
Write-Host "   .\publish-pact.ps1" -ForegroundColor Gray
Write-Host "   .\publish-pact.ps1 -ConsumerVersion '1.2.0' -Branch 'feature-x'" -ForegroundColor Gray
Write-Host "   .\publish-pact.ps1 -Tag 'new-feature'`n" -ForegroundColor Gray

Write-Host "3️⃣  Check if Safe to Deploy" -ForegroundColor Yellow
Write-Host "   .\can-i-deploy.ps1" -ForegroundColor Gray
Write-Host "   .\can-i-deploy.ps1 -ConsumerVersion '1.2.0'" -ForegroundColor Gray
Write-Host "   .\can-i-deploy.ps1 -Branch 'feature-x'`n" -ForegroundColor Gray

Write-Host "4️⃣  Run Interactive Demo" -ForegroundColor Yellow
Write-Host "   .\demo-workflow.ps1`n" -ForegroundColor Gray

Write-Host "5️⃣  Start Kafka Infrastructure" -ForegroundColor Yellow
Write-Host "   .\start-kafka.ps1`n" -ForegroundColor Gray

Write-Host "6️⃣  Send Events to Kafka" -ForegroundColor Yellow
Write-Host "   .\send-event.ps1 -Mode quick" -ForegroundColor Gray
Write-Host "   .\send-event.ps1 (interactive mode)`n" -ForegroundColor Gray

Write-Host "7️⃣  Start Consumer Application" -ForegroundColor Yellow
Write-Host "   cd src" -ForegroundColor Gray
Write-Host "   dotnet run`n" -ForegroundColor Gray

Write-Host "8️⃣  View Events in Kafka" -ForegroundColor Yellow
Write-Host "   .\view-events.ps1`n" -ForegroundColor Gray

Write-Host "9️⃣  Stop Kafka" -ForegroundColor Yellow
Write-Host "   .\stop-kafka.ps1`n" -ForegroundColor Gray

Write-Host "`n🔧 ALTERNATIVE COMMANDS (Without Scripts)`n" -ForegroundColor White

Write-Host "Publish Contract Using Docker:" -ForegroundColor Yellow
Write-Host @"
   docker run --rm -v "$PWD/tests/pacts:/pacts" pactfoundation/pact-cli:latest \
     publish /pacts/EventDrivenConsumer-EventDrivenProvider.json \
     --consumer-app-version=1.0.0 \
     --branch=main \
     --broker-base-url=https://dom-crosbie.pactflow.io \
     --broker-token=YOUR_TOKEN
"@ -ForegroundColor Gray

Write-Host "`nCan I Deploy Using Docker:" -ForegroundColor Yellow
Write-Host @"
   docker run --rm pactfoundation/pact-cli:latest \
     broker can-i-deploy \
     --pacticipant EventDrivenConsumer \
     --version 1.0.0 \
     --to-environment production \
     --broker-base-url=https://dom-crosbie.pactflow.io \
     --broker-token=YOUR_TOKEN
"@ -ForegroundColor Gray

Write-Host "`nSend Kafka Event Manually:" -ForegroundColor Yellow
Write-Host @"
   docker exec -it demo-kafka kafka-console-producer \
     --bootstrap-server localhost:9092 \
     --topic products
   
   Then type: {"id":"test-1","type":"Demo","name":"Test","version":"v1","event":"CREATED"}
"@ -ForegroundColor Gray

Write-Host "`nView Kafka Events:" -ForegroundColor Yellow
Write-Host @"
   docker exec -it demo-kafka kafka-console-consumer \
     --bootstrap-server localhost:9092 \
     --topic products \
     --from-beginning
"@ -ForegroundCstart-kafka.ps1                   - Start Kafka infrastructure" -ForegroundColor Gray
Write-Host "   send-event.ps1                    - Send events to Kafka" -ForegroundColor Gray
Write-Host "   view-events.ps1                   - View Kafka events" -ForegroundColor Gray
Write-Host "   stop-kafka.ps1                    - Stop Kafka infrastructure" -ForegroundColor Gray
Write-Host "   olor Gray

Write-Host "`n`n📂 PROJECT FILES`n" -ForegroundColor White

Write-Host "Source Code:" -ForegroundColor Yellow
Write-Host "   src/ProductEventProcessor.cs      - Core business logic" -ForegroundColor Gray
Write-Host "   src/Controllers/                  - API endpoints" -ForegroundColor Gray
Write-Host "   src/Repositories/                 - Data layer`n" -ForegroundColor Gray

Write-Host "Tests:" -ForegroundColor Yellow
Write-Host "   tests/ConsumerEventTests.cs       - Contract test definitions" -ForegroundColor Gray
Write-Host "   tests/pacts/                      - Generated contracts`n" -ForegroundColor Gray

Write-Host "Scripts:" -ForegroundColor Yellow
Write-Host "   publish-pact.ps1                  - Test + Publish workflow" -ForegroundColor Gray
Write-Host "   can-i-deploy.ps1                  - Deployment safety check" -ForegroundColor Gray
Write-Host "   demo-workflow.ps1                 - Interactive demo" -ForegroundColor Gray
Write-Host "   quick-reference.ps1               - This file`n" -ForegroundColor Gray

Write-Host "Documentation:" -ForegroundColor Yellow
Write-Host "   README.md                         - Main project README" -ForegroundColor Gray
Write-Host "   WORKSHOP-README.md                - Detailed learning guide`n" -ForegroundColor Gray

Write-Host "`n🌐 USEFUL LINKS`n" -ForegroundColor White

Write-Host "PactFlow Dashboard:" -ForegroundColor Yellow
Write-Host "   https://dom-crosbie.pactflow.io`n" -ForegroundColor Cyan

Write-Host "GitHub Repository:" -ForegroundColor Yellow
Write-Host "   https://github.com/Dom-Crosbie/EventDrivenConsumer`n" -ForegroundColor Cyan

Write-Host "Pact Documentation:" -ForegroundColor Yellow
Write-Host "Full Demo Workflow:" -ForegroundColor Yellow
Write-Host "   1. Start Kafka: .\start-kafka.ps1" -ForegroundColor Gray
Write-Host "   2. Start consumer app: cd src; dotnet run" -ForegroundColor Gray
Write-Host "   3. Send events: .\send-event.ps1 -Mode quick" -ForegroundColor Gray
Write-Host "   4. Verify events processed in consumer logs" -ForegroundColor Gray
Write-Host "   5. Run contract tests: cd tests; dotnet test" -ForegroundColor Gray
Write-Host "   6. Publish contract: .\publish-pact.ps1 -Tag 'new-feature'" -ForegroundColor Gray
Write-Host "   7. Check deployment: .\can-i-deploy.ps1`n" -ForegroundColor Gray

Write-Host "   https://docs.pact.io/`n" -ForegroundColor Cyan

Write-Host "`n💡 WORKFLOW EXAMPLE`n" -ForegroundColor White

Write-Host "Typical Development Workflow:" -ForegroundColor Yellow
Write-Host "   1. Make changes to consumer code" -ForegroundColor Gray
Write-Host "   2. Update contract test in tests/ConsumerEventTests.cs" -ForegroundColor Gray
Write-Host "   3. Run: .\publish-pact.ps1 -ConsumerVersion '1.2.0' -Branch 'feature-x'" -ForegroundColor Gray
Write-Host "   4. Wait for provider to verify the new contract" -ForegroundColor Gray
Write-Host "   5. Run: .\can-i-deploy.ps1 -ConsumerVersion '1.2.0'" -ForegroundColor Gray
Write-Host "   6. If safe, deploy to production" -ForegroundColor Gray
Write-Host "   7. Record deployment in PactFlow`n" -ForegroundColor Gray

Write-Host "Breaking Change Workflow:" -ForegroundColor Yellow
Write-Host "   1. Consumer adds new requirement (e.g., new field)" -ForegroundColor Gray
Write-Host "   2. Update contract test" -ForegroundColor Gray
Write-Host "   3. Publish with feature branch tag" -ForegroundColor Gray
Write-Host "   4. can-i-deploy will FAIL (provider hasn't updated yet)" -ForegroundColor Gray
Write-Host "   5. Notify provider team of new requirements" -ForegroundColor Gray
Write-Host "   6. Provider updates their code and verifies contract" -ForegroundColor Gray
Write-Host "   7. can-i-deploy now PASSES" -ForegroundColor Gray
Write-Host "   8. Both teams can deploy safely`n" -ForegroundColor Gray

Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "  Need more help? See README.md or WORKSHOP-README.md" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
