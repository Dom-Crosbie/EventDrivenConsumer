<#
.SYNOPSIS
    View events in the Kafka topic (consumer mode).

.DESCRIPTION
    Opens a Kafka console consumer to view all events in the products topic.
    Shows events from the beginning and continues to show new events as they arrive.
    
    Useful for debugging and verifying that events are being published correctly.

.PARAMETER ContainerName
    Kafka container name (default: demo-kafka)

.PARAMETER Topic
    Kafka topic to consume from (default: products)

.PARAMETER FromBeginning
    Start from the beginning of the topic (default: true)

.EXAMPLE
    .\view-events.ps1
    View all events from the beginning

.EXAMPLE
    .\view-events.ps1 -FromBeginning:$false
    View only new events

.ALTERNATIVE COMMAND LINE CALLS
    Using Docker:
    
    # From beginning
    docker exec -it demo-kafka kafka-console-consumer \
      --bootstrap-server localhost:9092 \
      --topic products \
      --from-beginning

    # Only new events
    docker exec -it demo-kafka kafka-console-consumer \
      --bootstrap-server localhost:9092 \
      --topic products

    # With formatting
    docker exec -it demo-kafka kafka-console-consumer \
      --bootstrap-server localhost:9092 \
      --topic products \
      --from-beginning \
      --formatter kafka.tools.DefaultMessageFormatter \
      --property print.timestamp=true \
      --property print.key=true

    Using kafkacat (if installed):
    
    # Consume and exit
    kafkacat -b localhost:9092 -t products -C -e
    
    # Consume continuously  
    kafkacat -b localhost:9092 -t products -C

.NOTES
    Press Ctrl+C to stop viewing events.
    Requires Kafka to be running (use .\start-kafka.ps1 first)
#>

param(
    [string]$ContainerName = "demo-kafka",
    [string]$Topic = "products",
    [bool]$FromBeginning = $true
)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Kafka Event Viewer" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# Check if Kafka is running
$kafkaRunning = docker ps --filter "name=$ContainerName" --format "{{.Names}}"
if (-not $kafkaRunning) {
    Write-Host "`n❌ Kafka is not running!" -ForegroundColor Red
    Write-Host "Start Kafka first: .\start-kafka.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n✅ Kafka is running" -ForegroundColor Green
Write-Host "`n📖 Starting consumer for topic: $Topic" -ForegroundColor White

if ($FromBeginning) {
    Write-Host "Mode: From beginning (all events)" -ForegroundColor Gray
} else {
    Write-Host "Mode: Only new events" -ForegroundColor Gray
}

Write-Host "`nPress Ctrl+C to stop viewing events`n" -ForegroundColor Yellow
Write-Host "================================================`n" -ForegroundColor Cyan

# Build command
$args = @(
    "exec", "-it", $ContainerName,
    "kafka-console-consumer",
    "--bootstrap-server", "localhost:9092",
    "--topic", $Topic
)

if ($FromBeginning) {
    $args += "--from-beginning"
}

# Execute
& docker $args
