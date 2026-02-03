# Network Security ML - Phishing Detection

An end-to-end machine learning project for detecting phishing websites using scikit-learn, FastAPI, MongoDB, and Docker. This project implements a complete MLOps pipeline with experiment tracking (MLflow + DagHub), automated deployment, and production-ready REST API.

## 🚀 Features

- **Automated ML Pipeline**: Complete training pipeline with data ingestion, validation, transformation, and model training
- **REST API**: FastAPI-based web service for real-time predictions with interactive Swagger docs
- **MongoDB Integration**: Scalable cloud data storage and retrieval from MongoDB Atlas
- **MLflow + DagHub**: Complete experiment tracking, metrics logging, and model versioning
- **Docker Deployment**: Production-ready containerized application with Docker Compose support
- **Batch Predictions**: Upload CSV files for bulk predictions via API
- **Drift Detection**: Automated data drift detection using Kolmogorov-Smirnov test
- **Logging & Exception Handling**: Comprehensive logging and custom exception handling throughout
- **Automated Scripts**: One-click deployment scripts for Windows (.ps1) and Linux (.sh)

## 📋 Tech Stack

- **Python 3.8+**
- **scikit-learn** - Machine learning models
- **FastAPI** - REST API framework
- **MongoDB Atlas** - Cloud NoSQL database
- **Pandas & NumPy** - Data processing
- **MLflow + DagHub** - Experiment tracking & model registry
- **Scipy** - Statistical tests for drift detection
- **Uvicorn** - ASGI server
- **Docker** - Containerization & deployment
- **Docker Compose** - Multi-container orchestration

## 📁 Project Structure

```
networksecurity/
├── networksecurity/          # Main package
│   ├── components/          # ML pipeline components
│   ├── pipeline/            # Training & prediction pipelines
│   ├── entity/              # Configuration & artifact entities
│   ├── utils/               # Utility functions
│   ├── exception/           # Custom exceptions
│   └── logging/             # Logging configuration
├── projectdoc/              # 📚 Comprehensive documentation
│   ├── PROJECT_OVERVIEW.md
│   ├── MONGODB_INTEGRATION.md
│   ├── MLFLOW_DAGHUB.md
│   ├── MODEL_PIPELINE.md
│   ├── API_DOCUMENTATION.md
│   ├── DOCKER_DEPLOYMENT.md
│   └── SETUP_GUIDE.md
├── Artifacts/               # Training artifacts & models (generated)
├── final_model/             # Production models
├── Network_Data/            # Dataset
├── templates/               # HTML templates
├── Dockerfile               # Docker image configuration
├── docker-compose.yml       # Docker Compose configuration
├── deploy-docker.ps1        # Windows deployment script
├── deploy-docker.sh         # Linux/Mac deployment script
├── app.py                   # FastAPI application
├── main.py                  # Training pipeline entry point
├── push_data.py             # MongoDB data upload script
├── requirements.txt         # Python dependencies
└── .env                     # Environment variables (MongoDB, AWS)
```

## 🛠️ Installation & Setup

### Prerequisites

- Python 3.8 or higher
- MongoDB Atlas account (or local MongoDB)
- Git

### 1. Clone the Repository

```bash
git clone https://github.com/aashishkumar-tech/network-security-ml.git
cd network-security-ml
```

### 2. Create Virtual Environment

```bash
# Windows
python -m venv venv
.\venv\Scripts\Activate.ps1

# Linux/Mac
python3 -m venv venv
source venv/bin/activate
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Environment Configuration

Create a `.env` file in the root directory:

```bash
# MongoDB Configuration
MONGODB_URL_KEY=mongodb+srv://your_username:your_password@cluster0.xxxxx.mongodb.net/?appName=Cluster0
MONGO_DB_URL=mongodb+srv://your_username:your_password@cluster0.xxxxx.mongodb.net/?appName=Cluster0

# AWS Configuration (Optional - for deployment)
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
AWS_REGION=us-east-1
```

### 5. Test MongoDB Connection

```bash
python test_mongodb.py
```

## 🚀 Usage

### Option 1: Docker Deployment (Recommended) 🐳

**Fastest way to get started:**

```powershell
# Windows PowerShell
.\deploy-docker.ps1

# Or manually
docker build -t network-security:latest .
docker run -d -p 8000:8000 --env-file .env network-security:latest
```

```bash
# Linux/Mac
chmod +x deploy-docker.sh
./deploy-docker.sh

# Or using Docker Compose
docker-compose up -d
```

**Access**: <http://localhost:8000/docs>

**📚 See**: [DOCKER_QUICKSTART.md](DOCKER_QUICKSTART.md) | [Docker Deployment Guide](projectdoc/DOCKER_DEPLOYMENT.md)

---

### Option 2: Local Development

#### Train Model Separately

```bash
python main.py
```

This runs the complete ML pipeline:

- Data ingestion from MongoDB
- Data validation
- Data transformation
- Model training
- Saves model artifacts in `Artifacts/` folder

#### Run Web Application

```bash
python app.py
```

- Server starts at `http://localhost:8000`
- API documentation: `http://localhost:8000/docs`

## 📡 API Endpoints

### 1. Train Model

```bash
GET http://localhost:8000/train
```

Triggers the training pipeline

### 2. Predict (Batch)

```bash
POST http://localhost:8000/predict
```

- Upload CSV file with features
- Returns predictions with HTML table view
- Saves results to `prediction_output/output.csv`

### API Documentation

Interactive API docs available at: `http://localhost:8000/docs`

## 🗄️ MongoDB Setup

1. Create a MongoDB Atlas account at <https://cloud.mongodb.com/>
2. Create a new cluster
3. **Database Access**: Create a user with read/write permissions
4. **Network Access**: Add your IP address or allow access from anywhere (0.0.0.0/0)
5. Get your connection string and update the `.env` file

---

## 🐳 Docker Deployment

### Quick Deploy with Automation Scripts

```powershell
# Windows PowerShell
.\deploy-docker.ps1
```

```bash
# Linux/Mac
chmod +x deploy-docker.sh
./deploy-docker.sh
```

### Manual Docker Commands

```bash
# Build Docker image
docker build -t network-security:latest .

# Run container
docker run -d \
  -p 8000:8000 \
  --name network-security-app \
  --env-file .env \
  -v $(pwd)/final_model:/app/final_model \
  --restart unless-stopped \
  network-security:latest

# View logs
docker logs -f network-security-app

# Access container
docker exec -it network-security-app bash

# Stop/Remove container
docker stop network-security-app
docker rm network-security-app
```

### Docker Compose Deployment

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Rebuild and restart
docker-compose up -d --build
```

**📚 Complete Docker Documentation**:

- [DOCKER_QUICKSTART.md](DOCKER_QUICKSTART.md) - Quick reference
- [Docker Deployment Guide](projectdoc/DOCKER_DEPLOYMENT.md) - Complete guide

---

## 📚 Comprehensive Documentation

All detailed documentation is available in the [`projectdoc/`](projectdoc/) folder:

1. **[PROJECT_OVERVIEW.md](projectdoc/PROJECT_OVERVIEW.md)** - Architecture, features, and project structure
2. **[MONGODB_INTEGRATION.md](projectdoc/MONGODB_INTEGRATION.md)** - MongoDB setup and data pipeline
3. **[MLFLOW_DAGHUB.md](projectdoc/MLFLOW_DAGHUB.md)** - Experiment tracking configuration
4. **[MODEL_PIPELINE.md](projectdoc/MODEL_PIPELINE.md)** - Complete ML pipeline explanation
5. **[API_DOCUMENTATION.md](projectdoc/API_DOCUMENTATION.md)** - FastAPI endpoints and usage
6. **[DOCKER_DEPLOYMENT.md](projectdoc/DOCKER_DEPLOYMENT.md)** - Docker deployment guide
7. **[SETUP_GUIDE.md](projectdoc/SETUP_GUIDE.md)** - Step-by-step setup instructions

---

## 📦 Deployment Options

### 1. Local Development

```bash
python app.py
```

### 2. Docker (Recommended for Production)

```bash
docker-compose up -d
```

### 3. Cloud Platforms

#### AWS EC2 with Docker

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Deploy
docker build -t network-security:latest .
docker run -d -p 8000:8000 --env-file .env network-security:latest
```

#### Docker Hub Deployment

```bash
# Tag and push
docker tag network-security:latest yourusername/network-security:latest
docker push yourusername/network-security:latest

# Pull and run anywhere
docker pull yourusername/network-security:latest
docker run -d -p 8000:8000 --env-file .env yourusername/network-security:latest
```

---

## 🔐 GitHub Secrets (For CI/CD)

If deploying via GitHub Actions, add these secrets:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION=us-east-1
AWS_ECR_LOGIN_URI
ECR_REPOSITORY_NAME
```

## 📊 Model Performance & Experiment Tracking

### MLflow + DagHub Integration

All training experiments are automatically logged to DagHub:

**View Experiments**: [https://dagshub.com/aashishkumar.tech/networksecurity/experiments](https://dagshub.com/aashishkumar.tech/networksecurity/experiments)

### Models Trained

- Random Forest Classifier
- Decision Tree Classifier
- Logistic Regression
- Gradient Boosting Classifier
- AdaBoost Classifier

### Tracked Metrics

- F1 Score
- Precision
- Recall Score
- Model Parameters (via GridSearchCV)

**Best model** is automatically selected based on test performance and saved to `final_model/`.

Performance metrics are logged during training and saved in artifacts.

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Aashish Kumar**

- GitHub: [@aashishkumar-tech](https://github.com/aashishkumar-tech)
- DagHub: [aashishkumar.tech](https://dagshub.com/aashishkumar.tech)

## 🙏 Acknowledgments

- Dataset: Phishing website detection dataset
- MLflow & DagHub for excellent experiment tracking platform
- FastAPI for amazing web framework
- MongoDB Atlas for cloud database
- Docker for containerization technology

---

## 🎯 Quick Start Summary

```bash
# 1. Deploy with Docker (Fastest)
.\deploy-docker.ps1  # Windows
./deploy-docker.sh   # Linux/Mac

# 2. Or run locally
python main.py && python app.py

# 3. Access API
http://localhost:8000/docs

# 4. View Experiments
https://dagshub.com/aashishkumar.tech/networksecurity/experiments
```

---

⭐ **Star this repository if you find it helpful!**

📚 **Check the [projectdoc/](projectdoc/) folder for comprehensive documentation**

🐳 **Docker deployment ready - See [DOCKER_QUICKSTART.md](DOCKER_QUICKSTART.md)**
