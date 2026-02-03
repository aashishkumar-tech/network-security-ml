#!/bin/bash

# Network Security Docker Deployment Script
# This script automates the Docker deployment process

set -e  # Exit on error

echo "🐳 Network Security - Docker Deployment"
echo "========================================"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

echo "✅ Docker is installed"

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker is not running. Please start Docker."
    exit 1
fi

echo "✅ Docker is running"

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ .env file not found. Please create it with MongoDB credentials."
    exit 1
fi

echo "✅ .env file found"

# Check if models exist
if [ ! -d "final_model" ] || [ ! -f "final_model/model.pkl" ]; then
    echo "⚠️  Models not found. Training the model first..."
    python main.py
fi

echo "✅ Models are ready"

# Build Docker image
echo ""
echo "📦 Building Docker image..."
docker build -t network-security:latest .

echo "✅ Docker image built successfully"

# Stop existing container if running
if docker ps -a | grep -q network-security-app; then
    echo "🛑 Stopping existing container..."
    docker stop network-security-app || true
    docker rm network-security-app || true
fi

# Run container
echo ""
echo "🚀 Starting container..."
docker run -d \
    -p 8000:8000 \
    --name network-security-app \
    --env-file .env \
    -v $(pwd)/final_model:/app/final_model \
    -v $(pwd)/logs:/app/logs \
    -v $(pwd)/prediction_output:/app/prediction_output \
    --restart unless-stopped \
    network-security:latest

echo "✅ Container started successfully"

# Wait for container to be healthy
echo ""
echo "⏳ Waiting for application to be ready..."
sleep 10

# Check if container is running
if docker ps | grep -q network-security-app; then
    echo "✅ Container is running"
    
    # Show logs
    echo ""
    echo "📋 Container logs:"
    docker logs --tail 20 network-security-app
    
    echo ""
    echo "🎉 Deployment successful!"
    echo ""
    echo "🌐 API is available at: http://localhost:8000"
    echo "📚 API Documentation: http://localhost:8000/docs"
    echo ""
    echo "Useful commands:"
    echo "  View logs:      docker logs -f network-security-app"
    echo "  Stop container: docker stop network-security-app"
    echo "  Restart:        docker restart network-security-app"
    echo "  Remove:         docker rm -f network-security-app"
else
    echo "❌ Container failed to start. Check logs:"
    docker logs network-security-app
    exit 1
fi
