# API Documentation

## 🌐 Overview

The Network Security API is built with **FastAPI** and provides endpoints for model training and batch prediction.

## 🚀 Starting the API

```bash
# Method 1: Direct execution
python app.py

# Method 2: Using uvicorn
uvicorn app:app --host 0.0.0.0 --port 8000

# Method 3: With reload (development)
uvicorn app:app --reload
```

**Access:**
- API: http://localhost:8000
- Interactive Docs: http://localhost:8000/docs
- Alternative Docs: http://localhost:8000/redoc

## 📡 Endpoints

### 1. Root Endpoint

**GET** `/`

Redirects to `/docs` (Swagger UI)

**Response:**
```
302 Redirect → /docs
```

---

### 2. Train Model

**GET** `/train`

Triggers the complete training pipeline.

**Process:**
1. Fetches data from MongoDB
2. Validates data
3. Transforms data
4. Trains models
5. Logs to MLflow/DagHub
6. Saves best model

**Request:**
```bash
curl -X GET http://localhost:8000/train
```

**Response:**
```json
"Training is successful"
```

**Time:** ~2-5 minutes depending on data size

**Side Effects:**
- Creates new artifact folder
- Updates `final_model/`
- Logs to DagHub
- Syncs to S3 (if configured)

---

### 3. Predict

**POST** `/predict`

Upload CSV file for batch predictions.

**Request:**
```bash
curl -X POST http://localhost:8000/predict \
  -F "file=@test_data.csv"
```

**Python Example:**
```python
import requests

url = "http://localhost:8000/predict"
files = {"file": open("test_data.csv", "rb")}
response = requests.post(url, files=files)
print(response.text)  # HTML table
```

**Input CSV Format:**
Must contain 29 feature columns (all except 'Result'):
```csv
having_IP_Address,URL_Length,Shortining_Service,...
1,54,0,...
0,23,1,...
```

**Response:**
HTML table with predictions

**Example Response:**
```html
<table class="table table-striped">
  <thead>
    <tr>
      <th>having_IP_Address</th>
      <th>URL_Length</th>
      ...
      <th>predicted_column</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>1</td>
      <td>54</td>
      ...
      <td>1</td>  <!-- Legitimate -->
    </tr>
    <tr>
      <td>0</td>
      <td>23</td>
      ...
      <td>0</td>  <!-- Phishing -->
    </tr>
  </tbody>
</table>
```

**Prediction Values:**
- `0` = Phishing website (malicious)
- `1` = Legitimate website (safe)

**Output File:**
Predictions also saved to: `prediction_output/output.csv`

---

## 🔧 API Implementation

**File:** `app.py`

### Initialization

```python
from fastapi import FastAPI, File, UploadFile, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.templating import Jinja2Templates

app = FastAPI()

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

templates = Jinja2Templates(directory="./templates")
```

### Training Endpoint

```python
@app.get("/train")
async def train_route():
    try:
        train_pipeline = TrainingPipeline()
        train_pipeline.run_pipeline()
        return Response("Training is successful")
    except Exception as e:
        raise NetworkSecurityException(e, sys)
```

### Prediction Endpoint

```python
@app.post("/predict")
async def predict_route(request: Request, file: UploadFile = File(...)):
    try:
        # Read uploaded CSV
        df = pd.read_csv(file.file)
        
        # Load models
        preprocessor = load_object("final_model/preprocessor.pkl")
        final_model = load_object("final_model/model.pkl")
        
        # Create network model
        network_model = NetworkModel(
            preprocessor=preprocessor,
            model=final_model
        )
        
        # Predict
        y_pred = network_model.predict(df)
        df['predicted_column'] = y_pred
        
        # Save results
        df.to_csv('prediction_output/output.csv')
        
        # Return HTML table
        table_html = df.to_html(classes='table table-striped')
        return templates.TemplateResponse(
            "table.html", 
            {"request": request, "table": table_html}
        )
        
    except Exception as e:
        raise NetworkSecurityException(e, sys)
```

---

## 🎨 Frontend Template

**File:** `templates/table.html`

```html
<!DOCTYPE html>
<html>
<head>
    <title>Predictions</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <h1>Prediction Results</h1>
        {{ table | safe }}
    </div>
</body>
</html>
```

---

## 🔐 Security

### CORS
All origins allowed for development. For production:

```python
origins = [
    "https://yourdomain.com",
    "https://app.yourdomain.com"
]
```

### File Upload Limits
Default FastAPI limits apply (16MB). To change:

```python
from fastapi import FastAPI

app = FastAPI()
app.state.max_content_length = 50 * 1024 * 1024  # 50MB
```

---

## 📊 Response Codes

| Code | Description |
|------|-------------|
| 200  | Success |
| 400  | Bad Request (invalid CSV format) |
| 500  | Internal Server Error |

---

## 🧪 Testing with Swagger UI

1. Start API: `python app.py`
2. Open: http://localhost:8000/docs
3. Click endpoint to expand
4. Click "Try it out"
5. Upload file or execute
6. View response

---

## 📝 Example Test Scripts

### Test Training

```python
import requests

response = requests.get("http://localhost:8000/train")
print(response.text)
```

### Test Prediction

```python
import requests

url = "http://localhost:8000/predict"
files = {"file": ("test.csv", open("test_data.csv", "rb"), "text/csv")}
response = requests.post(url, files=files)

# Save response HTML
with open("predictions.html", "w") as f:
    f.write(response.text)
```

### Test with curl

```bash
# Training
curl http://localhost:8000/train

# Prediction
curl -X POST \
  -F "file=@Network_Data/phisingData.csv" \
  http://localhost:8000/predict \
  -o predictions.html
```

---

## 🚀 Deployment

### Docker

```bash
# Build
docker build -t network-security .

# Run
docker run -p 8000:8000 network-security
```

### AWS/Cloud

Environment variables needed:
```env
MONGO_DB_URL=...
MONGODB_URL_KEY=...
```

---

## 📁 Related Files

- `app.py` - FastAPI application
- `templates/table.html` - HTML template
- `networksecurity/pipeline/training_pipeline.py` - Training logic
- `networksecurity/utils/ml_utils/model/estimator.py` - NetworkModel class
- `networksecurity/utils/main_utils/utils.py` - Helper functions

---

## 💡 Tips

1. **Development Mode**: Use `uvicorn app:app --reload`
2. **Check Logs**: Monitor console output for errors
3. **Test Locally**: Use Swagger UI before deployment
4. **Save Predictions**: Check `prediction_output/output.csv`
5. **Model Updates**: Run `/train` to refresh model
