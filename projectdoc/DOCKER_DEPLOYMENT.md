# Docker Deployment Guide

## 🐳 Overview

This guide covers deploying the Network Security ML application using Docker for consistent, portable deployment across any environment.

## 📋 Prerequisites

- Docker Desktop installed ([Download](https://www.docker.com/products/docker-desktop))
- Docker running and verified: `docker --version`
- Project setup completed (models trained)

## 🚀 Quick Start

### Build Docker Image

```bash
docker build -t network-security:latest .
```

### Run Container

```bash
docker run -d \
  -p 8000:8000 \
  --name network-security-app \
  --env-file .env \
  network-security:latest
```

**Access API**: <http://localhost:8000>

## 📄 Dockerfile Explanation

```dockerfile
FROM python:3.8-slim-buster

# Set working directory
WORKDIR /app

# Copy requirements first (Docker layer caching)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy entire project
COPY . .

# Install package in editable mode
RUN pip install -e .

# Expose port
EXPOSE 8000

# Run application
CMD ["python", "app.py"]
```

## 🔧 Docker Commands Reference

### Building Images

```bash
# Build image
docker build -t network-security:latest .

# Build with specific tag
docker build -t network-security:v1.0 .

# Build without cache (fresh build)
docker build --no-cache -t network-security:latest .
```

### Running Containers

```bash
# Run in background (detached mode)
docker run -d -p 8000:8000 --name network-security-app network-security:latest

# Run with environment variables
docker run -d -p 8000:8000 --env-file .env network-security:latest

# Run with volume mount (for local development)
docker run -d -p 8000:8000 \
  -v $(pwd)/final_model:/app/final_model \
  network-security:latest

# Run in foreground (see logs)
docker run -p 8000:8000 network-security:latest
```

### Container Management

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# View container logs
docker logs network-security-app

# Follow logs (real-time)
docker logs -f network-security-app

# Stop container
docker stop network-security-app

# Start stopped container
docker start network-security-app

# Restart container
docker restart network-security-app

# Remove container
docker rm network-security-app

# Remove container (force)
docker rm -f network-security-app
```

### Image Management

```bash
# List images
docker images

# Remove image
docker rmi network-security:latest

# Remove unused images
docker image prune

# View image details
docker inspect network-security:latest
```

## 🔐 Environment Variables in Docker

### Method 1: Using .env file (Recommended)

Create `.env.docker` file:

```env
MONGO_DB_URL=mongodb+srv://username:password@cluster.mongodb.net/
MONGODB_URL_KEY=mongodb+srv://username:password@cluster.mongodb.net/
```

Run with env file:

```bash
docker run -d -p 8000:8000 --env-file .env.docker network-security:latest
```

### Method 2: Pass individual variables

```bash
docker run -d -p 8000:8000 \
  -e MONGO_DB_URL="mongodb+srv://..." \
  -e MONGODB_URL_KEY="mongodb+srv://..." \
  network-security:latest
```

### Method 3: Docker Compose (see section below)

## 🐳 Docker Compose Setup

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  network-security:
    build: .
    image: network-security:latest
    container_name: network-security-app
    ports:
      - "8000:8000"
    env_file:
      - .env
    volumes:
      - ./final_model:/app/final_model
      - ./logs:/app/logs
      - ./prediction_output:/app/prediction_output
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/docs"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### Docker Compose Commands

```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Rebuild and start
docker-compose up -d --build

# Remove everything (containers, networks, volumes)
docker-compose down -v
```

## 📊 Multi-Stage Build (Optimized)

Create optimized Dockerfile for production:

```dockerfile
# Build stage
FROM python:3.8-slim-buster AS builder

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Runtime stage
FROM python:3.8-slim-buster

WORKDIR /app

# Copy Python dependencies from builder
COPY --from=builder /root/.local /root/.local

# Copy application code
COPY . .

# Install package
RUN pip install -e .

# Update PATH
ENV PATH=/root/.local/bin:$PATH

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD python -c "import requests; requests.get('http://localhost:8000/docs')"

# Run application
CMD ["python", "app.py"]
```

## 🚀 Deployment Scenarios

### 1. Local Development

```bash
# Build and run
docker build -t network-security:dev .
docker run -d -p 8000:8000 \
  -v $(pwd):/app \
  --env-file .env \
  network-security:dev
```

### 2. Production Deployment

```bash
# Build optimized image
docker build -t network-security:prod -f Dockerfile.prod .

# Run with restart policy
docker run -d \
  -p 8000:8000 \
  --restart=always \
  --env-file .env.prod \
  --name network-security-prod \
  network-security:prod
```

### 3. Cloud Deployment (AWS ECR)

```bash
# Login to AWS ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Tag image
docker tag network-security:latest \
  <account-id>.dkr.ecr.us-east-1.amazonaws.com/network-security:latest

# Push to ECR
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/network-security:latest
```

### 4. Docker Hub Deployment

```bash
# Login to Docker Hub
docker login

# Tag image
docker tag network-security:latest yourusername/network-security:latest

# Push to Docker Hub
docker push yourusername/network-security:latest

# Pull and run on any machine
docker pull yourusername/network-security:latest
docker run -d -p 8000:8000 yourusername/network-security:latest
```

## 🔍 Debugging Docker Containers

### Access Container Shell

```bash
# Bash shell
docker exec -it network-security-app bash

# Python shell
docker exec -it network-security-app python

# Run specific command
docker exec -it network-security-app ls /app/final_model
```

### Check Container Resources

```bash
# View resource usage
docker stats network-security-app

# View container processes
docker top network-security-app

# View port mappings
docker port network-security-app
```

### View Container Details

```bash
# Full inspect
docker inspect network-security-app

# Get IP address
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' network-security-app

# Get environment variables
docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' network-security-app
```

## 📦 Volume Management

### Persist Data with Volumes

```bash
# Create named volume
docker volume create network-security-data

# Run with volume
docker run -d -p 8000:8000 \
  -v network-security-data:/app/final_model \
  network-security:latest

# List volumes
docker volume ls

# Inspect volume
docker volume inspect network-security-data

# Remove volume
docker volume rm network-security-data
```

## 🌐 Networking

### Custom Network

```bash
# Create network
docker network create network-security-net

# Run container in network
docker run -d -p 8000:8000 \
  --network network-security-net \
  --name network-security-app \
  network-security:latest

# List networks
docker network ls

# Inspect network
docker network inspect network-security-net
```

## ⚡ Performance Optimization

### Reduce Image Size

```dockerfile
# Use slim base image
FROM python:3.8-slim-buster

# Multi-stage build
FROM python:3.8-slim AS builder
...

# Clean up after installation
RUN pip install --no-cache-dir -r requirements.txt && \
    rm -rf /root/.cache/pip
```

### Layer Caching

```dockerfile
# Copy requirements first (cache this layer)
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy code later (changes more frequently)
COPY . .
```

### .dockerignore File

Create `.dockerignore`:

```
venv/
__pycache__/
*.pyc
.git/
.env
logs/
Artifacts/
.vscode/
.idea/
```

## 🐛 Common Issues & Solutions

### Issue: Port already in use

```bash
# Solution 1: Use different port
docker run -p 8001:8000 network-security:latest

# Solution 2: Stop conflicting container
docker ps
docker stop <conflicting-container>
```

### Issue: Environment variables not working

```bash
# Verify env file path
docker run --env-file ./.env network-security:latest

# Check loaded env variables
docker exec network-security-app env | grep MONGO
```

### Issue: Model files not found

```bash
# Check if files exist in image
docker run network-security:latest ls -la /app/final_model

# Solution: Copy models before building
cp -r final_model/* .
docker build -t network-security:latest .
```

### Issue: Container exits immediately

```bash
# View logs
docker logs network-security-app

# Run interactively to debug
docker run -it network-security:latest bash
```

## ✅ Pre-Deployment Checklist

- [ ] Models trained (`final_model/` exists)
- [ ] `.env` file configured with credentials
- [ ] Docker installed and running
- [ ] Ports available (8000 not in use)
- [ ] Sufficient disk space for image
- [ ] Network connectivity for MongoDB
- [ ] Test API locally first

## 🚀 Complete Deployment Workflow

```bash
# 1. Ensure models are trained
python main.py

# 2. Build Docker image
docker build -t network-security:latest .

# 3. Test locally
docker run -d -p 8000:8000 --env-file .env --name test-app network-security:latest

# 4. Verify API
curl http://localhost:8000/docs

# 5. Run tests
curl http://localhost:8000/train

# 6. Check logs
docker logs test-app

# 7. Stop test container
docker stop test-app && docker rm test-app

# 8. Deploy to production
docker run -d \
  -p 8000:8000 \
  --restart=always \
  --env-file .env.prod \
  --name network-security-prod \
  network-security:latest
```

## 📊 Monitoring in Docker

### View Logs

```bash
# Real-time logs
docker logs -f network-security-app

# Last 100 lines
docker logs --tail 100 network-security-app

# Logs with timestamps
docker logs -t network-security-app
```

### Resource Monitoring

```bash
# Live stats
docker stats network-security-app

# Export logs to file
docker logs network-security-app > app.log 2>&1
```

## 🎯 Next Steps

After successful Docker deployment:

1. ✅ Test all API endpoints
2. ✅ Monitor container health
3. ✅ Set up automated backups
4. ✅ Configure CI/CD pipeline
5. ✅ Deploy to cloud platform (AWS/Azure/GCP)
6. ✅ Set up monitoring (Prometheus/Grafana)
7. ✅ Implement load balancing

## 🔗 Related Resources

- [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
