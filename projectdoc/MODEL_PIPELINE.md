# Model Pipeline Documentation

## 🔄 Pipeline Overview

The Network Security ML pipeline is a **modular, end-to-end** system for phishing detection. It follows software engineering best practices with clear separation of concerns.

## 📐 Architecture

```
Data Ingestion → Data Validation → Data Transformation → 
Model Training → Model Evaluation → Model Deployment
```

Each stage is:

- ✅ **Independent**: Can run separately
- ✅ **Configurable**: Uses config classes
- ✅ **Traceable**: Produces artifacts
- ✅ **Logged**: Full logging support
- ✅ **Error-Handled**: Custom exceptions

## 🏗️ Pipeline Components

### 1️⃣ Data Ingestion

**File**: `networksecurity/components/data_ingestion.py`

**Purpose**: Fetch data from MongoDB and split into train/test sets

**Process:**

```python
1. Connect to MongoDB
2. Fetch collection as DataFrame
3. Save to feature store (CSV)
4. Split into train/test (80/20)
5. Save split data
```

**Configuration:**

```python
class DataIngestionConfig:
    - feature_store_file_path
    - training_file_path
    - testing_file_path
    - train_test_split_ratio: 0.2
    - collection_name: "NetworkData"
    - database_name: "AashishKumarTechDB"
```

**Output Artifact:**

```python
DataIngestionArtifact:
    - trained_file_path: path to train.csv
    - test_file_path: path to test.csv
```

**Location:**

```
Artifacts/{timestamp}/data_ingestion/
├── feature_store/
│   └── phisingData.csv
└── ingested/
    ├── train.csv
    └── test.csv
```

---

### 2️⃣ Data Validation

**File**: `networksecurity/components/data_validation.py`

**Purpose**: Validate data quality and detect drift

**Process:**

```python
1. Read train and test data
2. Validate number of columns (30 expected)
3. Detect dataset drift using KS-test
4. Generate drift report (YAML)
5. Save validated data
```

**Configuration:**

```python
class DataValidationConfig:
    - valid_data_dir
    - invalid_data_dir
    - drift_report_file_path
```

**Key Methods:**

#### Column Validation

```python
def validate_number_of_columns(dataframe):
    """Check if dataframe has expected columns"""
    schema_columns = 30  # From schema.yaml
    return len(dataframe.columns) == schema_columns
```

#### Drift Detection

```python
def detect_dataset_drift(base_df, current_df, threshold=0.05):
    """
    Use Kolmogorov-Smirnov test to detect distribution changes
    """
    for column in base_df.columns:
        ks_result = ks_2samp(base_df[column], current_df[column])
        if ks_result.pvalue <= threshold:
            drift_detected = True
```

**Output Artifact:**

```python
DataValidationArtifact:
    - validation_status: bool
    - valid_train_file_path
    - valid_test_file_path
    - drift_report_file_path
```

**Location:**

```
Artifacts/{timestamp}/data_validation/
├── validated/
│   ├── train.csv
│   └── test.csv
└── drift_report/
    └── report.yaml
```

**Drift Report Format:**

```yaml
having_IP_Address:
  p_value: 0.234
  drift_status: false
URL_Length:
  p_value: 0.012
  drift_status: true
```

---

### 3️⃣ Data Transformation

**File**: `networksecurity/components/data_transformation.py`

**Purpose**: Prepare data for model training

**Process:**

```python
1. Read validated data
2. Separate features (X) and target (y)
3. Replace target values: -1 → 0 (binary classification)
4. Initialize KNN Imputer
5. Fit on training data
6. Transform both train and test
7. Combine features + target
8. Save as numpy arrays
9. Save preprocessor object
```

**Configuration:**

```python
class DataTransformationConfig:
    - transformed_train_file_path
    - transformed_test_file_path
    - transformed_object_file_path
```

**Preprocessing Pipeline:**

```python
Pipeline([
    ("imputer", KNNImputer(
        missing_values=np.nan,
        n_neighbors=3,
        weights="uniform"
    ))
])
```

**Why KNN Imputer?**

- Handles missing values intelligently
- Uses neighbor values for imputation
- Better than mean/median for structured data
- Preserves data relationships

**Output Artifact:**

```python
DataTransformationArtifact:
    - transformed_object_file_path: preprocessing.pkl
    - transformed_train_file_path: train.npy
    - transformed_test_file_path: test.npy
```

**Location:**

```
Artifacts/{timestamp}/data_transformation/
├── transformed/
│   ├── train.npy
│   └── test.npy
└── transformed_object/
    └── preprocessing.pkl

final_model/
└── preprocessor.pkl  # Copy for deployment
```

---

### 4️⃣ Model Training

**File**: `networksecurity/components/model_trainer.py`

**Purpose**: Train and select best model

**Process:**

```python
1. Load transformed arrays
2. Define models and hyperparameters
3. Grid search for each model
4. Train all models
5. Evaluate on test set
6. Select best model (highest R² score)
7. Calculate classification metrics
8. Log to MLflow/DagHub
9. Save model artifacts
```

**Configuration:**

```python
class ModelTrainerConfig:
    - trained_model_file_path
    - expected_accuracy: 0.6
    - overfitting_underfitting_threshold: 0.05
```

**Models:**

```python
models = {
    "Random Forest": RandomForestClassifier(verbose=1),
    "Decision Tree": DecisionTreeClassifier(),
    "Gradient Boosting": GradientBoostingClassifier(verbose=1),
    "Logistic Regression": LogisticRegression(verbose=1),
    "AdaBoost": AdaBoostClassifier(),
}
```

**Hyperparameter Grid:**

```python
params = {
    "Random Forest": {
        'n_estimators': [8, 16, 32, 128, 256]
    },
    "Gradient Boosting": {
        'learning_rate': [0.1, 0.01, 0.05, 0.001],
        'subsample': [0.6, 0.7, 0.75, 0.85, 0.9],
        'n_estimators': [8, 16, 32, 64, 128, 256]
    },
    "Decision Tree": {
        'criterion': ['gini', 'entropy', 'log_loss']
    },
    "AdaBoost": {
        'learning_rate': [0.1, 0.01, 0.001],
        'n_estimators': [8, 16, 32, 64, 128, 256]
    }
}
```

**Model Selection:**

```python
def train_model():
    # Grid search all models
    model_report = evaluate_models(X_train, y_train, X_test, y_test, models, params)
    
    # Select best
    best_model_score = max(model_report.values())
    best_model_name = max(model_report, key=model_report.get)
    best_model = models[best_model_name]
    
    return best_model
```

**Evaluation Metrics:**

```python
def get_classification_score(y_true, y_pred):
    return ClassificationMetricArtifact(
        f1_score=f1_score(y_true, y_pred),
        precision_score=precision_score(y_true, y_pred),
        recall_score=recall_score(y_true, y_pred)
    )
```

**MLflow Logging:**

```python
def track_mlflow(best_model, metrics):
    with mlflow.start_run():
        mlflow.log_metric("f1_score", metrics.f1_score)
        mlflow.log_metric("precision", metrics.precision_score)
        mlflow.log_metric("recall_score", metrics.recall_score)
        mlflow.sklearn.log_model(best_model, "model")
```

**Output Artifact:**

```python
ModelTrainerArtifact:
    - trained_model_file_path
    - train_metric_artifact: ClassificationMetricArtifact
    - test_metric_artifact: ClassificationMetricArtifact
```

**Location:**

```
Artifacts/{timestamp}/model_trainer/
└── trained_model/
    └── model.pkl

final_model/
├── model.pkl          # Best model
└── preprocessor.pkl   # Preprocessing pipeline
```

---

## 🎯 Complete Pipeline Execution

**File**: `networksecurity/pipeline/training_pipeline.py`

```python
class TrainingPipeline:
    def run_pipeline(self):
        # Stage 1: Data Ingestion
        data_ingestion_artifact = self.start_data_ingestion()
        
        # Stage 2: Data Validation
        data_validation_artifact = self.start_data_validation(
            data_ingestion_artifact
        )
        
        # Stage 3: Data Transformation
        data_transformation_artifact = self.start_data_transformation(
            data_validation_artifact
        )
        
        # Stage 4: Model Training
        model_trainer_artifact = self.start_model_trainer(
            data_transformation_artifact
        )
        
        # Optional: Sync to S3
        self.sync_artifact_dir_to_s3()
        self.sync_saved_model_dir_to_s3()
        
        return model_trainer_artifact
```

**Entry Point**: `main.py`

```python
if __name__ == '__main__':
    trainingpipelineconfig = TrainingPipelineConfig()
    
    # Run each stage
    data_ingestion = DataIngestion(dataingestionconfig)
    dataingestionartifact = data_ingestion.initiate_data_ingestion()
    
    data_validation = DataValidation(dataingestionartifact, data_validation_config)
    data_validation_artifact = data_validation.initiate_data_validation()
    
    # ... continues for all stages
```

---

## 📊 Data Flow Diagram

```
MongoDB
   ↓
[Data Ingestion] → train.csv, test.csv
   ↓
[Data Validation] → validated data + drift report
   ↓
[Data Transformation] → train.npy, test.npy + preprocessor.pkl
   ↓
[Model Training] → model.pkl + metrics
   ↓
MLflow/DagHub (experiment tracking)
   ↓
final_model/ (deployment artifacts)
```

---

## 🎨 Design Patterns Used

### 1. **Config-Artifact Pattern**

Each component has:

- **Config**: Input parameters
- **Artifact**: Output results

### 2. **Factory Pattern**

```python
class TrainingPipeline:
    def start_data_ingestion(self):
        config = DataIngestionConfig(self.training_pipeline_config)
        component = DataIngestion(config)
        return component.initiate_data_ingestion()
```

### 3. **Pipeline Pattern**

Sequential execution with artifact passing

### 4. **Singleton Pattern**

```python
class TrainingPipelineConfig:
    def __init__(self, timestamp=datetime.now()):
        self.timestamp = timestamp.strftime("%m_%d_%Y_%H_%M_%S")
        # Single timestamp for entire pipeline run
```

---

## 🔧 Configuration Management

**File**: `networksecurity/constant/training_pipeline/__init__.py`

```python
# Pipeline
PIPELINE_NAME = "NetworkSecurity"
ARTIFACT_DIR = "Artifacts"

# Data
TARGET_COLUMN = "Result"
FILE_NAME = "phisingData.csv"
TRAIN_FILE_NAME = "train.csv"
TEST_FILE_NAME = "test.csv"

# Transformation
DATA_TRANSFORMATION_IMPUTER_PARAMS = {
    "missing_values": np.nan,
    "n_neighbors": 3,
    "weights": "uniform"
}

# Model Training
MODEL_TRAINER_EXPECTED_SCORE = 0.6
MODEL_TRAINER_OVER_FIITING_UNDER_FITTING_THRESHOLD = 0.05
```

---

## 📁 Artifact Structure

```
Artifacts/
└── {timestamp}/          # e.g., 02_03_2026_19_53_03
    ├── data_ingestion/
    ├── data_validation/
    ├── data_transformation/
    └── model_trainer/
```

Each run creates a new timestamped folder for complete traceability.

---

## 🐛 Error Handling

**Custom Exception**: `NetworkSecurityException`

```python
class NetworkSecurityException(Exception):
    def __init__(self, error_message, error_details: sys):
        self.error_message = error_message
        _, _, exc_tb = error_details.exc_info()
        self.lineno = exc_tb.tb_lineno
        self.file_name = exc_tb.tb_frame.f_code.co_filename
```

**Usage in Pipeline:**

```python
try:
    # Component logic
except Exception as e:
    raise NetworkSecurityException(e, sys)
```

---

## 📝 Logging

**File**: `networksecurity/logging/logger.py`

```python
LOG_FILE = f"{datetime.now().strftime('%m_%d_%Y_%H_%M_%S')}.log"
logs_path = os.path.join(os.getcwd(), "logs", LOG_FILE)

logging.basicConfig(
    filename=LOG_FILE_PATH,
    format="[ %(asctime)s ] %(lineno)d %(name)s - %(levelname)s - %(message)s",
    level=logging.INFO
)
```

**Log Location:**

```
logs/
└── 02_03_2026_19_53_03.log
```

---

## ✅ Quality Checks

### Data Quality

- ✅ Column count validation
- ✅ Missing value handling
- ✅ Distribution drift detection

### Model Quality

- ✅ Minimum accuracy threshold (60%)
- ✅ Overfitting detection (train-test gap < 5%)
- ✅ Multiple model comparison

### Code Quality

- ✅ Modular architecture
- ✅ Exception handling
- ✅ Comprehensive logging
- ✅ Type hints in config classes

---

## 🚀 Running the Pipeline

```bash
# Full pipeline
python main.py

# Via API
python app.py
# Then: GET http://localhost:8000/train
```

---

## 🔗 Related Files

- `networksecurity/components/` - All pipeline components
- `networksecurity/entity/config_entity.py` - Configuration classes
- `networksecurity/entity/artifact_entity.py` - Artifact classes
- `networksecurity/pipeline/training_pipeline.py` - Pipeline orchestration
- `main.py` - Entry point
