# 🐳 Docker Quick Start Guide

## ⚡ Fastest Way to Deploy

### Option 1: Using Deployment Script (Recommended)

**Windows PowerShell:**

```powershell
.\deploy-docker.ps1
```

**Linux/Mac:**

```bash
chmod +x deploy-docker.sh
./deploy-docker.sh
```

### Option 2: Using Docker Compose

```bash
docker-compose up -d
```

### Option 3: Manual Docker Commands

```bash
# Build
docker build -t network-security:latest .

# Run
docker run -d -p 8000:8000 --env-file .env --name network-security-app network-security:latest
```

---

## 📋 Prerequisites Checklist

- [x] Docker Desktop installed and running
- [x] Models trained (run `python main.py` first)
- [x] `.env` file configured with MongoDB credentials
- [x] Port 8000 available

---

## 🚀 Step-by-Step Deployment

### Step 1: Ensure Models Exist

```bash
# Check if models are trained
ls final_model/

# If not, train them first
python main.py
```

### Step 2: Build Docker Image

```bash
docker build -t network-security:latest .
```

**Expected output:**

```
Successfully built abc123def456
Successfully tagged network-security:latest
```

### Step 3: Run Container

```bash
docker run -d \
  -p 8000:8000 \
  --name network-security-app \
  --env-file .env \
  -v $(pwd)/final_model:/app/final_model \
  network-security:latest
```

**Windows PowerShell:**

```powershell
docker run -d -p 8000:8000 --name network-security-app --env-file .env -v "${PWD}\final_model:/app/final_model" network-security:latest
```

### Step 4: Verify Deployment

```bash
# Check if container is running
docker ps

# View logs
docker logs network-security-app

# Test API
curl http://localhost:8000/docs
```

**Access API**: <http://localhost:8000>

---

## 🎯 Common Commands

### Container Management

```bash
# View running containers
docker ps

# View all containers
docker ps -a

# View logs (real-time)
docker logs -f network-security-app

# Stop container
docker stop network-security-app

# Start container
docker start network-security-app

# Restart container
docker restart network-security-app

# Remove container
docker rm -f network-security-app
```

### Image Management

```bash
# List images
docker images

# Remove image
docker rmi network-security:latest

# Rebuild image (no cache)
docker build --no-cache -t network-security:latest .
```

### Docker Compose Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Rebuild and start
docker-compose up -d --build
```

---

## 🔧 Configuration

### Environment Variables

Ensure `.env` file contains:

```env
MONGO_DB_URL=mongodb+srv://username:password@cluster.mongodb.net/
MONGODB_URL_KEY=mongodb+srv://username:password@cluster.mongodb.net/
```

### Port Configuration

Change port if 8000 is in use:

```bash
docker run -d -p 8001:8000 --name network-security-app network-security:latest
```

---

## 🐛 Troubleshooting

### Container Won't Start

```bash
# Check logs
docker logs network-security-app

# Run interactively
docker run -it network-security:latest bash
```

### Port Already in Use

```bash
# Windows: Find process using port
netstat -ano | findstr :8000

# Kill process
taskkill /PID <PID> /F

# Or use different port
docker run -d -p 8001:8000 network-security:latest
```

### Can't Connect to MongoDB

```bash
# Verify env variables
docker exec network-security-app env | grep MONGO

# Check if .env was loaded
docker run --env-file .env network-security:latest env
```

### Models Not Found

```bash
# Verify models in image
docker run network-security:latest ls -la /app/final_model

# Rebuild with models
docker build -t network-security:latest .
```

---

## ✅ Health Check

```bash
# Check container health
docker inspect --format='{{.State.Health.Status}}' network-security-app

# Manual health check
curl http://localhost:8000/docs
```

---

## 📊 Monitoring

### View Resource Usage

```bash
# Real-time stats
docker stats network-security-app

# Detailed info
docker inspect network-security-app
```

### Access Container

```bash
# Bash shell
docker exec -it network-security-app bash

# Check Python version
docker exec network-security-app python --version

# List files
docker exec network-security-app ls -la /app
```

---

## 🚀 Production Deployment

### Push to Docker Hub

```bash
# Login
docker login

# Tag image
docker tag network-security:latest yourusername/network-security:latest

# Push
docker push yourusername/network-security:latest
```

### Deploy on Any Server

```bash
# Pull image
docker pull yourusername/network-security:latest

# Run
docker run -d -p 8000:8000 --env-file .env yourusername/network-security:latest
```

---

## 🎉 Success Checklist

After deployment:

- [ ] Container is running: `docker ps`
- [ ] API accessible: <http://localhost:8000/docs>
- [ ] Logs look good: `docker logs network-security-app`
- [ ] Health check passing: `curl http://localhost:8000/docs`
- [ ] Can make predictions via API

---

## 📚 Next Steps

1. ✅ Test `/train` endpoint
2. ✅ Test `/predict` endpoint with sample data
3. ✅ Monitor container logs
4. ✅ Set up automated backups
5. ✅ Deploy to cloud (AWS/Azure/GCP)

---

## 🆘 Need Help?

- Check [DOCKER_DEPLOYMENT.md](projectdoc/DOCKER_DEPLOYMENT.md) for detailed guide
- View container logs: `docker logs network-security-app`
- Check Docker Desktop dashboard
- Verify .env file has correct credentials

---

**🐳 Happy Dockerizing!**
