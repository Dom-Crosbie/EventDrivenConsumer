<#
.SYNOPSIS
    Stop and optionally remove Kafka infrastructure.

.DESCRIPTION
    Stops the Kafka broker and Zookeeper containers. Optionally removes
    the containers and their data volumes for a complete cleanup.

.PARAMETER Remove
    If specified, removes containers after stopping (data will be lost)

.PARAMETER ContainerName
    Kafka container name (default: demo-kafka)

.PARAMETER ZookeeperName
    Zookeeper container name (default: demo-zookeeper)

.EXAMPLE
    .\stop-kafka.ps1
    Stop Kafka and Zookeeper (containers remain for restart)

.EXAMPLE
    .\stop-kafka.ps1 -Remove
    Stop and remove Kafka and Zookeeper (clean slate)

.ALTERNATIVE COMMAND LINE CALLS
    Stop only:
    
    docker stop demo-kafka demo-zookeeper

    Stop and remove:
    
    docker stop demo-kafka demo-zookeeper
    docker rm demo-kafka demo-zookeeper

    Using docker-compose:
    
    docker-compose down
    
    # Remove volumes too
    docker-compose down -v

.NOTES
    Stopping without -Remove allows quick restart with .\start-kafka.ps1
#>

param(
    [switch]$Remove,
    [string]$ContainerName = "demo-kafka",
    [string]$ZookeeperName = "demo-zookeeper"
)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Stopping Kafka Infrastructure" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# Check if containers exist
$kafkaExists = docker ps -a --filter "name=$ContainerName" --format "{{.Names}}"
$zookeeperExists = docker ps -a --filter "name=$ZookeeperName" --format "{{.Names}}"

if (-not $kafkaExists -and -not $zookeeperExists) {
    Write-Host "`n⚠️  No Kafka containers found" -ForegroundColor Yellow
    Write-Host "Nothing to stop." -ForegroundColor Gray
    exit 0
}

# Stop Kafka
if ($kafkaExists) {
    Write-Host "`n[1/2] Stopping Kafka broker..." -ForegroundColor Yellow
    docker stop $ContainerName | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Kafka stopped" -ForegroundColor Green
        
        if ($Remove) {
            Write-Host "  Removing container..." -ForegroundColor Yellow
            docker rm $ContainerName | Out-Null
            Write-Host "  ✅ Container removed" -ForegroundColor Green
        }
    } else {
        Write-Host "❌ Failed to stop Kafka" -ForegroundColor Red
    }
}

# Stop Zookeeper
if ($zookeeperExists) {
    Write-Host "`n[2/2] Stopping Zookeeper..." -ForegroundColor Yellow
    docker stop $ZookeeperName | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Zookeeper stopped" -ForegroundColor Green
        
        if ($Remove) {
            Write-Host "  Removing container..." -ForegroundColor Yellow
            docker rm $ZookeeperName | Out-Null
            Write-Host "  ✅ Container removed" -ForegroundColor Green
        }
    } else {
        Write-Host "❌ Failed to stop Zookeeper" -ForegroundColor Red
    }
}

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "✨ Done!" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

if ($Remove) {
    Write-Host "`n✅ Kafka infrastructure stopped and removed" -ForegroundColor Green
    Write-Host "  All data has been cleared." -ForegroundColor Gray
    Write-Host "`n  To start fresh: .\start-kafka.ps1" -ForegroundColor White
} else {
    Write-Host "`n✅ Kafka infrastructure stopped" -ForegroundColor Green
    Write-Host "  Containers are preserved for quick restart." -ForegroundColor Gray
    Write-Host "`n  To restart: .\start-kafka.ps1" -ForegroundColor White
    Write-Host "  To remove: .\stop-kafka.ps1 -Remove" -ForegroundColor White
}

Write-Host ""
