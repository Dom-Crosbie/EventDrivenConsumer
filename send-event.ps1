<#
.SYNOPSIS
    Send product events to Kafka for testing and demos.

.DESCRIPTION
    This script provides three ways to send events to Kafka:
    1. Interactive mode - Opens Kafka console producer for manual entry
    2. Quick send mode - Sends a predefined test event
    3. Custom event mode - Sends a custom JSON event
    
    Perfect for testing the consumer application and demonstrating event processing.

.PARAMETER Mode
    'interactive' - Open console producer for manual entry (default)
    'quick' - Send a test event immediately
    'custom' - Send a custom event (requires -Event parameter)

.PARAMETER Event
    JSON string containing the event to send (used with -Mode 'custom')

.PARAMETER ContainerName
    Kafka container name (default: demo-kafka)

.PARAMETER Topic
    Kafka topic to send to (default: products)

.EXAMPLE
    .\send-event.ps1
    Open interactive console producer

.EXAMPLE
    .\send-event.ps1 -Mode quick
    Send a test event immediately

.EXAMPLE
    .\send-event.ps1 -Mode custom -Event '{"id":"prod-123","type":"Widget","name":"Super Widget","version":"v2.0","event":"UPDATED"}'
    Send a custom event

.ALTERNATIVE COMMAND LINE CALLS
    Interactive producer:
    
    docker exec -it demo-kafka kafka-console-producer \
      --bootstrap-server localhost:9092 \
      --topic products

    Send from file:
    
    echo '{"id":"test-1","type":"Demo","name":"Test","version":"v1","event":"CREATED"}' | \
    docker exec -i demo-kafka kafka-console-producer \
      --bootstrap-server localhost:9092 \
      --topic products

    Using kafkacat (if installed):
    
    echo '{"id":"test-1","type":"Demo","name":"Test","version":"v1","event":"CREATED"}' | \
    kafkacat -b localhost:9092 -t products -P

.NOTES
    Requires Kafka to be running (use .\start-kafka.ps1 first)
#>

param(
    [ValidateSet('interactive', 'quick', 'custom')]
    [string]$Mode = "interactive",
    [string]$Event = "",
    [string]$ContainerName = "demo-kafka",
    [string]$Topic = "products"
)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Kafka Event Producer" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# Check if Kafka is running
$kafkaRunning = docker ps --filter "name=$ContainerName" --format "{{.Names}}"
if (-not $kafkaRunning) {
    Write-Host "`n❌ Kafka is not running!" -ForegroundColor Red
    Write-Host "Start Kafka first: .\start-kafka.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n✅ Kafka is running" -ForegroundColor Green

# Sample events for quick mode
$sampleEvents = @(
    '{"id":"prod-001","type":"Electronics","name":"Laptop Pro","version":"v1.0","event":"CREATED"}',
    '{"id":"prod-002","type":"Furniture","name":"Office Chair","version":"v1.0","event":"CREATED"}',
    '{"id":"prod-003","type":"Books","name":"PowerShell Guide","version":"v2.0","event":"UPDATED"}'
)

switch ($Mode) {
    "interactive" {
        Write-Host "`n📝 Starting Interactive Console Producer" -ForegroundColor White
        Write-Host "Topic: $Topic" -ForegroundColor Gray
        Write-Host "`nType your JSON events and press Enter after each one." -ForegroundColor Yellow
        Write-Host "Press Ctrl+C when done.`n" -ForegroundColor Yellow
        
        Write-Host "Example events:" -ForegroundColor White
        Write-Host '  {"id":"test-1","type":"Demo","name":"Test Product","version":"v1.0","event":"CREATED"}' -ForegroundColor Gray
        Write-Host '  {"id":"test-2","type":"Widget","name":"Widget X","version":"v2.0","event":"UPDATED"}' -ForegroundColor Gray
        Write-Host '  {"id":"test-3","type":"Gadget","name":"Gadget Y","version":"v1.0","event":"DELETED"}' -ForegroundColor Gray
        Write-Host ""
        
        docker exec -it $ContainerName kafka-console-producer --bootstrap-server localhost:9092 --topic $Topic
    }
    
    "quick" {
        Write-Host "`n🚀 Quick Send Mode - Sending test events..." -ForegroundColor White
        Write-Host "Topic: $Topic`n" -ForegroundColor Gray
        
        foreach ($json in $sampleEvents) {
            Write-Host "Sending: " -NoNewline -ForegroundColor Yellow
            Write-Host $json -ForegroundColor Gray
            
            # Use echo to properly pipe JSON to docker
            echo $json | docker exec -i $ContainerName kafka-console-producer --bootstrap-server localhost:9092 --topic $Topic
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✅ Sent" -ForegroundColor Green
            } else {
                Write-Host "  ❌ Failed" -ForegroundColor Red
            }
            Start-Sleep -Milliseconds 500
        }
        
        Write-Host "`n✨ Sent $($sampleEvents.Count) events successfully!" -ForegroundColor Green
        Write-Host "`nCheck your consumer application to see them processed." -ForegroundColor White
    }
    
    "custom" {
        if (-not $Event) {
            Write-Host "`n❌ Custom mode requires -Event parameter!" -ForegroundColor Red
            Write-Host "Example: .\send-event.ps1 -Mode custom -Event '{`"id`":`"test`"}'" -ForegroundColor Yellow
            exit 1
        }
        
        Write-Host "`n📤 Sending custom event..." -ForegroundColor White
        Write-Host "Topic: $Topic" -ForegroundColor Gray
        Write-Host "Event: $Event`n" -ForegroundColor Gray
        
        echo $Event | docker exec -i $ContainerName kafka-console-producer --bootstrap-server localhost:9092 --topic $Topic
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Event sent successfully!" -ForegroundColor Green
        } else {
            Write-Host "❌ Failed to send event" -ForegroundColor Red
            exit 1
        }
    }
}

Write-Host ""
