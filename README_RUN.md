# Network Security Project - Setup & Run Instructions

## Prerequisites

- Python 3.8 or higher
- MongoDB account (MongoDB Atlas recommended)
- Git installed

## Step-by-Step Setup

### 1. Configure Environment Variables

Edit the `.env` file and add your MongoDB connection string:

```
MONGO_DB_URL=mongodb+srv://your_username:your_password@cluster.mongodb.net/
MONGODB_URL_KEY=mongodb+srv://your_username:your_password@cluster.mongodb.net/
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Push Data to MongoDB (One-time setup)

First, ensure you have data in `Network_Data/phisingData.csv`, then run:

```bash
python push_data.py
```

### 4. Run Training Pipeline

To train the model:

```bash
python main.py
```

This will:

- Ingest data from MongoDB
- Validate the data
- Transform the data
- Train the model
- Save the model to `final_model/` directory

### 5. Run FastAPI Application

To start the web application:

```bash
python app.py
```

Or use uvicorn directly:

```bash
uvicorn app:app --host 0.0.0.0 --port 8000
```

The application will be available at: `http://localhost:8000`

### 6. API Endpoints

#### Train Model

```
GET http://localhost:8000/train
```

#### Predict

```
POST http://localhost:8000/predict
```

Upload a CSV file with the same columns as your training data.

## Optional: AWS S3 Configuration

If you want to sync artifacts to S3:

1. Install AWS CLI
2. Configure credentials: `aws configure`
3. Update the bucket name in `networksecurity/constant/training_pipeline/__init__.py`

## Optional: MLflow Tracking

The project is configured to use DagHub for MLflow tracking. To use your own:

1. Create a DagHub account
2. Update credentials in `networksecurity/components/model_trainer.py` or set as environment variables

## Troubleshooting

### MongoDB Connection Issues

- Ensure your IP address is whitelisted in MongoDB Atlas
- Verify connection string format
- Check network connectivity

### Import Errors

- Ensure all packages are installed: `pip install -r requirements.txt`
- Verify Python version compatibility

### Model Training Errors

- Check if data exists in MongoDB
- Verify schema.yaml matches your data columns
- Ensure sufficient disk space for artifacts

## Project Structure

```
networksecurity/
├── main.py                  # Training pipeline entry point
├── app.py                   # FastAPI application
├── requirements.txt         # Python dependencies
├── .env                     # Environment variables (create this)
├── networksecurity/         # Main package
│   ├── components/          # Data processing components
│   ├── pipeline/            # Training & prediction pipelines
│   ├── utils/               # Utility functions
│   └── constant/            # Configuration constants
└── Artifacts/               # Generated during training
```
