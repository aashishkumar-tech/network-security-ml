# Network Security - Phishing Detection Project

## 🎯 Project Overview

This is an end-to-end machine learning project for **phishing website detection** using network security data. The project implements a complete MLOps pipeline with experiment tracking, data versioning, and deployment capabilities.

## 🏗️ Architecture

```
Data Source (MongoDB) → Data Ingestion → Data Validation → 
Data Transformation → Model Training → Model Evaluation → 
Model Deployment (FastAPI + Docker) → Predictions
```

## 🔑 Key Features

### 1. **MongoDB Integration**

- Cloud-based data storage using MongoDB Atlas
- Dynamic data fetching from database
- Scalable data management
- Collection: `NetworkData`
- Database: `AashishKumarTechDB`

### 2. **MLflow Experiment Tracking**

- Automatic logging of model metrics
- Parameter tracking
- Model versioning
- Experiment comparison

### 3. **DagHub Integration**

- Centralized experiment tracking
- Model registry
- Collaboration features
- Git + Data + Models in one place

### 4. **Docker Deployment**

- Containerized application for consistent deployment
- Docker Compose support for easy orchestration
- Automated deployment scripts (Windows & Linux)
- Production-ready container configuration
- Health checks and restart policies
- Volume mounting for persistent data

### 5. **Modular Pipeline Architecture**

- **Data Ingestion**: MongoDB → CSV
- **Data Validation**: Schema validation + Drift detection
- **Data Transformation**: KNN Imputation + Feature engineering
- **Model Training**: Multiple algorithms with GridSearchCV
- **Model Evaluation**: Classification metrics

### 6. **Production-Ready API**

- FastAPI for REST API
- CSV file upload for batch predictions
- Real-time inference
- HTML response with prediction table

## 📊 Models Trained

- Random Forest Classifier
- Decision Tree Classifier
- Gradient Boosting Classifier
- Logistic Regression
- AdaBoost Classifier

**Best model selected automatically** based on test R² score.

## 🔄 Data Flow

1. **Push Data**: `push_data.py` → MongoDB
2. **Training**: `main.py` → Artifacts + Models
3. **Prediction**: `app.py` → API endpoints

## 📁 Project Structure

```
networksecurity/
├── networksecurity/           # Main package
│   ├── components/            # Pipeline components
│   ├── pipeline/              # Training & batch prediction
│   ├── constant/              # Configuration constants
│   ├── entity/                # Data classes (config, artifacts)
│   ├── exception/             # Custom exception handling
│   ├── logging/               # Logging configuration
│   ├── utils/                 # Utility functions
│   └── cloud/                 # AWS S3 sync (optional)
├── Artifacts/                 # Training artifacts (generated)
├── final_model/               # Production models
├── Network_Data/              # Raw data
├── projectdoc/                # Documentation
├── .env                       # Environment variables
├── main.py                    # Training pipeline entry
├── app.py                     # FastAPI application
├── push_data.py               # Data upload script
└── requirements.txt           # Dependencies
```

## 🚀 Technology Stack

- **Python 3.8+**
- **Machine Learning**: scikit-learn
- **Experiment Tracking**: MLflow + DagHub
- **Database**: MongoDB Atlas
- **API Framework**: FastAPI
- **Data Processing**: Pandas, NumPy
- **Validation**: Scipy (KS test for drift detection)

## 📈 Performance Metrics

The model is evaluated using:

- **F1 Score**: Harmonic mean of precision and recall
- **Precision**: Correct positive predictions
- **Recall**: Coverage of actual positives

All metrics logged to DagHub for tracking and comparison.

## 🔐 Security Features

- Environment variables for credentials
- MongoDB authentication
- Secure API endpoints
- Exception handling throughout

## 🌐 Deployment Ready

- **Dockerized Application**:
  - Optimized Dockerfile with multi-stage builds
  - Docker Compose for orchestration
  - Automated deployment scripts (.ps1 for Windows, .sh for Linux)
  - Health checks and auto-restart policies
- **AWS S3 Integration**: Artifact storage and model versioning
- **FastAPI**: Scalable API serving with interactive docs
- **Model Versioning**: Timestamped artifacts for traceability

## 📝 Use Cases

- **Real-time phishing detection**
- **Batch URL analysis**
- **Security monitoring systems**
- **Cybersecurity research**

## 🎓 Learning Outcomes

This project demonstrates:

- End-to-end ML pipeline development
- MLOps best practices
- Cloud database integration
- Experiment tracking
- API development
- Production-ready code structure
