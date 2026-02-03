# MLflow & DagHub Integration Documentation

## 🎯 Overview

This project uses **DagHub + MLflow** for comprehensive experiment tracking, model versioning, and collaboration. DagHub provides a unified platform combining Git, Data, and ML experiments.

## 🏗️ Architecture

```
Training Code → MLflow Logging → DagHub Platform → 
Experiment Tracking + Model Registry + Visualization
```

## 🔧 Setup & Configuration

### DagHub Repository

- **Owner**: `aashishkumar.tech`
- **Repo**: `networksecurity`
- **URL**: <https://dagshub.com/aashishkumar.tech/networksecurity>

### Configuration in Code

File: `networksecurity/components/model_trainer.py`

```python
import dagshub
import mlflow

# Initialize DagHub connection
dagshub.init(
    repo_owner='aashishkumar.tech', 
    repo_name='networksecurity', 
    mlflow=True
)
```

This single line automatically configures:

- MLflow tracking URI
- Authentication credentials
- Experiment logging

## 📊 What Gets Logged

### 1. **Metrics** (Per Model)

File: `networksecurity/components/model_trainer.py`

```python
def track_mlflow(best_model, classificationmetric):
    with mlflow.start_run():
        # Log metrics
        mlflow.log_metric("f1_score", f1_score)
        mlflow.log_metric("precision", precision_score)
        mlflow.log_metric("recall_score", recall_score)
        
        # Log model
        mlflow.sklearn.log_model(best_model, "model")
```

**Metrics Logged:**

- **F1 Score**: Harmonic mean of precision and recall
- **Precision Score**: True positives / (True positives + False positives)
- **Recall Score**: True positives / (True positives + False negatives)

### 2. **Models**

- Trained scikit-learn models
- Model artifacts (pickled files)
- Model metadata

### 3. **Parameters** (via GridSearchCV)

- `n_estimators`
- `learning_rate`
- `subsample`
- `criterion`
- Model hyperparameters

## 🔄 Logging Flow

### Training Pipeline Execution

```python
# 1. Train multiple models
models = {
    "Random Forest": RandomForestClassifier(),
    "Decision Tree": DecisionTreeClassifier(),
    "Gradient Boosting": GradientBoostingClassifier(),
    "Logistic Regression": LogisticRegression(),
    "AdaBoost": AdaBoostClassifier(),
}

# 2. Evaluate with GridSearchCV
model_report = evaluate_models(X_train, y_train, X_test, y_test, models, params)

# 3. Select best model
best_model_name = max(model_report, key=model_report.get)
best_model = models[best_model_name]

# 4. Calculate metrics
train_metrics = get_classification_score(y_train, y_train_pred)
test_metrics = get_classification_score(y_test, y_test_pred)

# 5. Log to MLflow (2 runs: train + test)
track_mlflow(best_model, train_metrics)  # Run 1
track_mlflow(best_model, test_metrics)   # Run 2
```

## 📈 Accessing Experiments

### DagHub Web Interface

**URL**: <https://dagshub.com/aashishkumar.tech/networksecurity>

#### 1. **Experiments Tab**

Click "Experiments" to view:

- All training runs
- Run timestamps
- Metrics comparison
- Best performing models

#### 2. **Models Tab**

View registered models:

- Model versions
- Download links
- Model metadata

#### 3. **Comparison View**

Compare multiple runs:

- Side-by-side metrics
- Parameter differences
- Performance trends

## 🎨 MLflow UI Features

### Run Details

Each run shows:

- **Run ID**: Unique identifier
- **Start Time**: When training started
- **Duration**: Training time
- **Status**: Success/Failed
- **User**: Who ran the experiment

### Metrics Visualization

- Line charts for metric trends
- Scatter plots for parameter correlation
- Box plots for metric distribution

### Model Artifacts

- Download trained models
- View model signatures
- Check model requirements

## 🔑 Key Benefits

### 1. **Experiment Tracking**

✅ Never lose track of model experiments
✅ Compare different approaches easily
✅ Reproduce results with exact parameters

### 2. **Collaboration**

✅ Share experiments with team
✅ Review others' work
✅ Centralized experiment history

### 3. **Model Registry**

✅ Version control for models
✅ Track model lineage
✅ Deploy specific versions

### 4. **Visualization**

✅ Interactive charts
✅ Metric comparison
✅ Performance trends

### 5. **Integration**

✅ Works with Git
✅ No additional infrastructure
✅ Free for public repositories

## 🛠️ Implementation Details

### Automatic Logging

```python
with mlflow.start_run():
    # Training code here
    
    # Metrics logged automatically
    mlflow.log_metric("accuracy", accuracy)
    
    # Model logged with dependencies
    mlflow.sklearn.log_model(model, "model")
    
# Run ends automatically (context manager)
```

### Multiple Runs in Pipeline

The project logs **2 runs per training**:

1. **Training Metrics Run**: Performance on training data
2. **Test Metrics Run**: Performance on test data

This allows comparing train vs. test performance to detect overfitting.

### Model Metadata

Each logged model includes:

- Python version
- scikit-learn version
- Model class name
- Feature names
- Model signature

## 📋 Best Practices Implemented

### 1. **Consistent Naming**

```python
mlflow.log_metric("f1_score", value)  # Not "f1", "F1Score", etc.
```

### 2. **Descriptive Run Names**

DagHub auto-generates names like: `auspicious-ray-40`

### 3. **Complete Context**

All metrics, parameters, and models logged together

### 4. **Error Handling**

```python
try:
    with mlflow.start_run():
        # Training code
except Exception as e:
    # Log failure
    raise NetworkSecurityException(e, sys)
```

## 🔗 Related Files

- `networksecurity/components/model_trainer.py` - MLflow integration
- `networksecurity/utils/ml_utils/metric/classification_metric.py` - Metric calculation
- `networksecurity/pipeline/training_pipeline.py` - Pipeline orchestration

## 📊 Example Experiment View

After running `python main.py`, visit:
<https://dagshub.com/aashishkumar.tech/networksecurity/experiments>

You'll see something like:

```
Run Name          | F1 Score | Precision | Recall | Model
------------------|----------|-----------|--------|------------------
auspicious-ray-40 | 0.92     | 0.94      | 0.90   | Random Forest
cheerful-wind-39  | 0.88     | 0.89      | 0.87   | Gradient Boosting
```

## 🚀 Quick Commands

### View Experiments

```bash
# Open in browser
https://dagshub.com/aashishkumar.tech/networksecurity/experiments
```

### Run Training with Logging

```bash
python main.py
```

## 💡 Tips

1. **Check experiments after each training run**
2. **Compare different hyperparameters**
3. **Track model improvements over time**
4. **Use run URLs for documentation**
5. **Download best models for deployment**

## ⚠️ Important Notes

- DagHub is **free for public repositories**
- Experiments are **publicly visible**
- Models are stored in **DagHub storage**
- Internet connection required for logging
- Failed runs still appear in UI
