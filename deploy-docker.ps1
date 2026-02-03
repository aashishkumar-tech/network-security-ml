# Network Security Docker Deployment Script (Windows PowerShell)

Write-Host "🐳 Network Security - Docker Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Check if Docker is installed
try {
    docker --version | Out-Null
    Write-Host "✅ Docker is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not installed. Please install Docker Desktop first." -ForegroundColor Red
    exit 1
}

# Check if Docker is running
try {
    docker info | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    exit 1
}

# Check if .env file exists
if (-Not (Test-Path .env)) {
    Write-Host "❌ .env file not found. Please create it with MongoDB credentials." -ForegroundColor Red
    exit 1
}
Write-Host "✅ .env file found" -ForegroundColor Green

# Check if models exist
if (-Not (Test-Path "final_model\model.pkl")) {
    Write-Host "⚠️  Models not found. Training the model first..." -ForegroundColor Yellow
    python main.py
}
Write-Host "✅ Models are ready" -ForegroundColor Green

# Build Docker image
Write-Host "`n📦 Building Docker image..." -ForegroundColor Cyan
docker build -t network-security:latest .

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Docker image built successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Docker build failed" -ForegroundColor Red
    exit 1
}

# Stop existing container if running
$existingContainer = docker ps -a --filter "name=network-security-app" --format "{{.Names}}"
if ($existingContainer -eq "network-security-app") {
    Write-Host "`n🛑 Stopping existing container..." -ForegroundColor Yellow
    docker stop network-security-app | Out-Null
    docker rm network-security-app | Out-Null
}

# Run container
Write-Host "`n🚀 Starting container..." -ForegroundColor Cyan
docker run -d `
    -p 8000:8000 `
    --name network-security-app `
    --env-file .env `
    -v "${PWD}\final_model:/app/final_model" `
    -v "${PWD}\logs:/app/logs" `
    -v "${PWD}\prediction_output:/app/prediction_output" `
    --restart unless-stopped `
    network-security:latest

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Container started successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Container failed to start" -ForegroundColor Red
    docker logs network-security-app
    exit 1
}

# Wait for container to be healthy
Write-Host "`n⏳ Waiting for application to be ready..." -ForegroundColor Cyan
Start-Sleep -Seconds 10

# Check if container is running
$runningContainer = docker ps --filter "name=network-security-app" --format "{{.Names}}"
if ($runningContainer -eq "network-security-app") {
    Write-Host "✅ Container is running" -ForegroundColor Green
    
    # Show logs
    Write-Host "`n📋 Container logs:" -ForegroundColor Cyan
    docker logs --tail 20 network-security-app
    
    Write-Host "`n🎉 Deployment successful!" -ForegroundColor Green
    Write-Host "`n🌐 API is available at: http://localhost:8000" -ForegroundColor Cyan
    Write-Host "📚 API Documentation: http://localhost:8000/docs" -ForegroundColor Cyan
    Write-Host "`nUseful commands:" -ForegroundColor Yellow
    Write-Host "  View logs:      docker logs -f network-security-app"
    Write-Host "  Stop container: docker stop network-security-app"
    Write-Host "  Restart:        docker restart network-security-app"
    Write-Host "  Remove:         docker rm -f network-security-app"
} else {
    Write-Host "❌ Container failed to start. Check logs:" -ForegroundColor Red
    docker logs network-security-app
    exit 1
}
