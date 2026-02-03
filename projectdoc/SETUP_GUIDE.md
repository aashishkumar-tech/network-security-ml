# Complete Setup Guide

## 📋 Prerequisites

- Python 3.8 or higher
- MongoDB Atlas account
- DagHub account (optional but recommended)
- Git installed
- 2GB free disk space

## 🚀 Step-by-Step Setup

### Step 1: Clone or Navigate to Project

```bash
cd "C:\Users\Aashish kumar\Videos\networksecurity"
```

### Step 2: Create Virtual Environment

```bash
# Create venv
python -m venv venv

# Activate
# Windows PowerShell:
.\venv\Scripts\Activate.ps1

# Windows CMD:
.\venv\Scripts\activate.bat

# Linux/Mac:
source venv/bin/activate
```

### Step 3: Install Dependencies

```bash
pip install -r requirements.txt
```

**Installed packages:**

- pandas, numpy - Data processing
- scikit-learn - Machine learning
- pymongo - MongoDB connection
- fastapi, uvicorn - API framework
- mlflow, dagshub - Experiment tracking
- scipy - Statistical tests
- pyyaml - Configuration files

### Step 4: Configure Environment Variables

File: `.env` (already exists)

```env
# MongoDB Configuration
MONGO_DB_URL=mongodb+srv://username:password@cluster.mongodb.net/
MONGODB_URL_KEY=mongodb+srv://username:password@cluster.mongodb.net/

# AWS (Optional)
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
AWS_REGION=us-east-1
```

**MongoDB Setup:**

1. Go to <https://www.mongodb.com/cloud/atlas>
2. Create free cluster
3. Create database user
4. Get connection string
5. Replace in `.env`

### Step 5: Setup DagHub (Optional)

1. Go to <https://dagshub.com>
2. Create account
3. Create repository named `networksecurity`
4. Credentials already configured in code:

   ```python
   dagshub.init(
       repo_owner='aashishkumar.tech',
       repo_name='networksecurity',
       mlflow=True
   )
   ```

### Step 6: Push Data to MongoDB

```bash
python push_data.py
```

**Output:**

```
mongodb+srv://...
[{'having_IP_Address': 1, 'URL_Length': 54, ...}, ...]
11430  # Number of records inserted
```

### Step 7: Verify Setup

```bash
# Test MongoDB connection
python test_mongodb.py
```

### Step 8: Run Training Pipeline

```bash
python main.py
```

**Expected Output:**

```
[ 2026-02-03 19:53:03 ] Initiate the data ingestion
[ 2026-02-03 19:53:05 ] Data Initiation Completed
[ 2026-02-03 19:53:05 ] Initiate the data Validation
[ 2026-02-03 19:53:07 ] data Validation Completed
[ 2026-02-03 19:53:07 ] data Transformation started
[ 2026-02-03 19:53:10 ] data Transformation completed
[ 2026-02-03 19:53:10 ] Model Training started
Fitting 3 folds for each of 5 candidates, totalling 15 fits
...
[ 2026-02-03 19:53:45 ] Model Training artifact created
🏃 View run at: https://dagshub.com/aashishkumar.tech/networksecurity.mlflow/...
```

**Duration:** ~2-5 minutes

### Step 9: Start API Server

```bash
python app.py
```

**Output:**

```
INFO:     Started server process
INFO:     Uvicorn running on http://0.0.0.0:8000
```

### Step 10: Test API

Open browser: <http://localhost:8000/docs>

Or use curl:

```bash
curl http://localhost:8000/train
```

---

## 📁 Project Structure After Setup

```
networksecurity/
├── venv/                     # Virtual environment ✓
├── .env                      # Environment variables ✓
├── Artifacts/                # Generated during training ✓
│   └── {timestamp}/
├── final_model/              # Production models ✓
│   ├── model.pkl
│   └── preprocessor.pkl
├── logs/                     # Training logs ✓
├── prediction_output/        # Prediction results ✓
│   └── output.csv
├── Network_Data/             # Raw data
│   └── phisingData.csv
└── projectdoc/               # Documentation ✓
```

---

## ✅ Verification Checklist

- [ ] Virtual environment activated
- [ ] All packages installed
- [ ] MongoDB connection working
- [ ] DagHub repository created
- [ ] Data pushed to MongoDB
- [ ] Training completed successfully
- [ ] `final_model/` folder created
- [ ] API server running
- [ ] Swagger docs accessible

---

## 🐛 Troubleshooting

### Issue: Import Errors

```bash
# Solution: Reinstall package in editable mode
pip install -e .
```

### Issue: MongoDB Connection Failed

```bash
# Check .env file
cat .env | grep MONGO_DB_URL

# Test connection
python test_mongodb.py
```

### Issue: No Data from MongoDB

```bash
# Push data again
python push_data.py
```

### Issue: Port Already in Use

```bash
# Kill process on port 8000 (Windows)
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# Use different port
uvicorn app:app --port 8001
```

### Issue: MLflow Logging Failed

```bash
# Check DagHub repo exists
# Visit: https://dagshub.com/aashishkumar.tech/networksecurity

# Check internet connection
ping dagshub.com
```

---

## 🔄 Update Workflow

### Update Dependencies

```bash
pip install --upgrade -r requirements.txt
```

### Retrain Model

```bash
python main.py
```

### Deploy New Model

```bash
# Model automatically updates in final_model/
# Restart API
python app.py
```

---

## 📊 Monitoring

### Check Logs

```bash
# View latest log file
ls logs/
cat logs/{latest_log_file}.log
```

### Check Experiments

Visit: <https://dagshub.com/aashishkumar.tech/networksecurity/experiments>

### Check Artifacts

```bash
ls Artifacts/
ls -lah final_model/
```

---

## 🚀 Production Deployment

### Docker Deployment

```bash
# Build image
docker build -t network-security:latest .

# Run container
docker run -p 8000:8000 --env-file .env network-security:latest
```

### Cloud Deployment (AWS/Azure/GCP)

1. Set environment variables in cloud console
2. Deploy Docker container
3. Configure load balancer
4. Setup auto-scaling
5. Monitor with CloudWatch/Application Insights

---

## 📚 Next Steps

1. ✅ Setup complete
2. ✅ Training successful
3. ✅ API running
4. 📊 View experiments on DagHub
5. 🧪 Test predictions with sample data
6. 🚀 Deploy to production (optional)
7. 📈 Monitor model performance
8. 🔄 Retrain periodically with new data

---

## 🆘 Getting Help

- Check documentation in `projectdoc/`
- Review error logs in `logs/`
- Check DagHub experiments for training issues
- Verify MongoDB Atlas dashboard for data issues

---

## 🎉 Success

If you reached here with all checks passing:

- ✅ Environment configured
- ✅ Data pipeline working
- ✅ Model trained
- ✅ API serving predictions
- ✅ Experiments tracked

**You're ready to use the Network Security ML system!** 🚀
