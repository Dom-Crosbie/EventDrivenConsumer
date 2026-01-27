<#
.SYNOPSIS
    Start Kafka instance for local development and demos.

.DESCRIPTION
    Starts a Kafka broker using Docker with Zookeeper. This provides the messaging
    infrastructure needed to run the consumer application and demo event processing.
    
    The Kafka instance runs in the background and persists until explicitly stopped.

.PARAMETER ContainerName
    Name for the Kafka container (default: demo-kafka)

.PARAMETER ZookeeperName
    Name for the Zookeeper container (default: demo-zookeeper)

.PARAMETER Port
    Kafka broker port (default: 9092)

.EXAMPLE
    .\start-kafka.ps1
    Start Kafka with default settings

.ALTERNATIVE COMMAND LINE CALLS
    Using docker-compose (recommended for production):
    
    Create docker-compose.yml:
    ```yaml
    version: '3'
    services:
      zookeeper:
        image: confluentinc/cp-zookeeper:latest
        environment:
          ZOOKEEPER_CLIENT_PORT: 2181
          ZOOKEEPER_TICK_TIME: 2000
      kafka:
        image: confluentinc/cp-kafka:latest
        depends_on:
          - zookeeper
        ports:
          - 9092:9092
        environment:
          KAFKA_BROKER_ID: 1
          KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
          KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092
          KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
    ```
    
    Then run:
    docker-compose up -d

    Using Docker CLI directly:
    
    # Start Zookeeper
    docker run -d --name demo-zookeeper \
      -p 2181:2181 \
      -e ZOOKEEPER_CLIENT_PORT=2181 \
      confluentinc/cp-zookeeper:latest

    # Start Kafka
    docker run -d --name demo-kafka \
      -p 9092:9092 \
      --link demo-zookeeper \
      -e KAFKA_ZOOKEEPER_CONNECT=demo-zookeeper:2181 \
      -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092 \
      -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 \
      confluentinc/cp-kafka:latest

.NOTES
    Requires Docker Desktop to be running.
#>

param(
    [string]$ContainerName = "demo-kafka",
    [string]$ZookeeperName = "demo-zookeeper",
    [int]$Port = 9092
)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Starting Kafka Infrastructure" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# Check if Docker is running
try {
    docker ps | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Docker is not running"
    }
} catch {
    Write-Host "`n❌ Docker is not running!" -ForegroundColor Red
    Write-Host "Please start Docker Desktop and try again." -ForegroundColor Yellow
    exit 1
}

Write-Host "`n✅ Docker is running" -ForegroundColor Green

# Check if containers already exist
$existingZookeeper = docker ps -a --filter "name=$ZookeeperName" --format "{{.Names}}"
$existingKafka = docker ps -a --filter "name=$ContainerName" --format "{{.Names}}"

if ($existingZookeeper -or $existingKafka) {
    Write-Host "`n⚠️  Kafka containers already exist!" -ForegroundColor Yellow
    
    if ($existingZookeeper) {
        $zkStatus = docker ps --filter "name=$ZookeeperName" --format "{{.Status}}"
        if ($zkStatus) {
            Write-Host "  Zookeeper ($ZookeeperName): Running ✅" -ForegroundColor Green
        } else {
            Write-Host "  Zookeeper ($ZookeeperName): Stopped" -ForegroundColor Gray
            Write-Host "  Starting existing Zookeeper..." -ForegroundColor Yellow
            docker start $ZookeeperName
        }
    }
    
    if ($existingKafka) {
        $kafkaStatus = docker ps --filter "name=$ContainerName" --format "{{.Status}}"
        if ($kafkaStatus) {
            Write-Host "  Kafka ($ContainerName): Running ✅" -ForegroundColor Green
            Write-Host "`n✨ Kafka is already running and ready!" -ForegroundColor Cyan
            Write-Host "  Broker: localhost:$Port" -ForegroundColor Gray
            exit 0
        } else {
            Write-Host "  Kafka ($ContainerName): Stopped" -ForegroundColor Gray
            Write-Host "  Starting existing Kafka..." -ForegroundColor Yellow
            docker start $ContainerName
            Write-Host "`n⏳ Waiting for Kafka to be ready..." -ForegroundColor Yellow
            Start-Sleep -Seconds 10
            Write-Host "✅ Kafka started!" -ForegroundColor Green
            Write-Host "  Broker: localhost:$Port" -ForegroundColor Gray
            exit 0
        }
    }
}

# Start Zookeeper
Write-Host "`n[1/3] Starting Zookeeper..." -ForegroundColor Yellow
docker run -d `
    --name $ZookeeperName `
    -p 2181:2181 `
    -e ZOOKEEPER_CLIENT_PORT=2181 `
    -e ZOOKEEPER_TICK_TIME=2000 `
    confluentinc/cp-zookeeper:latest

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ Failed to start Zookeeper" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Zookeeper started" -ForegroundColor Green
Start-Sleep -Seconds 5

# Start Kafka
Write-Host "`n[2/3] Starting Kafka broker..." -ForegroundColor Yellow
docker run -d `
    --name $ContainerName `
    -p ${Port}:9092 `
    --link ${ZookeeperName}:zookeeper `
    -e KAFKA_BROKER_ID=1 `
    -e KAFKA_ZOOKEEPER_CONNECT=${ZookeeperName}:2181 `
    -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092 `
    -e KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092 `
    -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 `
    confluentinc/cp-kafka:latest

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ Failed to start Kafka" -ForegroundColor Red
    Write-Host "Cleaning up Zookeeper..." -ForegroundColor Yellow
    docker stop $ZookeeperName
    docker rm $ZookeeperName
    exit 1
}

Write-Host "✅ Kafka broker started" -ForegroundColor Green

# Wait for Kafka to be ready
Write-Host "`n[3/3] Waiting for Kafka to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Create topics
Write-Host "`nCreating 'products' topic..." -ForegroundColor Yellow
docker exec $ContainerName kafka-topics --create `
    --bootstrap-server localhost:9092 `
    --topic products `
    --partitions 1 `
    --replication-factor 1 `
    --if-not-exists 2>$null

Write-Host "✅ Topic created" -ForegroundColor Green

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "✨ Kafka is ready!" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

Write-Host "`n📍 Connection Details:" -ForegroundColor White
Write-Host "  Broker: localhost:$Port" -ForegroundColor Gray
Write-Host "  Topic: products" -ForegroundColor Gray
Write-Host "  Zookeeper: localhost:2181" -ForegroundColor Gray

Write-Host "`n🔧 Next Steps:" -ForegroundColor White
Write-Host "  • Send events: .\send-event.ps1" -ForegroundColor Gray
Write-Host "  • Start consumer: cd src; dotnet run" -ForegroundColor Gray
Write-Host "  • Stop Kafka: .\stop-kafka.ps1" -ForegroundColor Gray

Write-Host ""
