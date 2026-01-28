<#
.SYNOPSIS
    Monitor Kafka events in real-time with Docker.

.DESCRIPTION
    Opens a Docker-based Kafka consumer that shows all events being published
    to the products topic in real-time. Useful for monitoring and debugging.

.PARAMETER Topic
    Kafka topic to monitor (default: products)

.PARAMETER ContainerName
    Kafka container name (default: demo-kafka)

.EXAMPLE
    .\monitor-kafka.ps1
    Monitor the products topic

.EXAMPLE
    .\monitor-kafka.ps1 -Topic "other-topic"
    Monitor a different topic
#>

param(
    [string]$Topic = "products",
    [string]$ContainerName = "demo-kafka"
)

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Kafka Event Monitor (Docker)" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# Check Kafka is running
$kafkaRunning = docker ps --filter "name=$ContainerName" --format "{{.Names}}"
if (-not $kafkaRunning) {
    Write-Host "`n❌ Kafka container '$ContainerName' is not running!" -ForegroundColor Red
    Write-Host "Start Kafka first: .\start-kafka.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n✅ Connected to Kafka" -ForegroundColor Green
Write-Host "Topic: $Topic" -ForegroundColor Gray
Write-Host "Container: $ContainerName" -ForegroundColor Gray

Write-Host "`n📡 Monitoring events (from beginning)..." -ForegroundColor White
Write-Host "Press Ctrl+C to stop`n" -ForegroundColor Yellow
Write-Host "-------------------------------------------" -ForegroundColor Cyan

# Run console consumer with formatting
docker exec -it $ContainerName kafka-console-consumer `
    --bootstrap-server localhost:9092 `
    --topic $Topic `
    --from-beginning `
    --property print.timestamp=true `
    --property print.key=false

Write-Host "`n-------------------------------------------" -ForegroundColor Cyan
Write-Host "Monitoring stopped" -ForegroundColor Gray
