# KrishiVue API - Agricultural ML API Server

FastAPI-based backend service for KrishiVue mobile application providing crop disease detection and crop recommendation using machine learning models.

## Features

### 1. Crop Disease Prediction
- **Endpoint**: `/predictCropDisease`
- **Model**: TensorFlow Keras model (Potato disease classification)
- **Classes**: 
  - Potato___Early_blight
  - Potato___healthy
  - POTATO__Late_blight
- **Input**: Image file (JPG/PNG)
- **Output**: Disease class and confidence score

### 2. Crop Recommendation
- **Endpoint**: `/predictCrop`
- **Model**: Scikit-learn classifier (joblib)
- **Input Parameters**:
  - N (Nitrogen content)
  - P (Phosphorus content)
  - K (Potassium content)
  - Temperature (°C)
  - Humidity (%)
  - pH level
  - Rainfall (mm)
- **Output**: Recommended crop from 22 crop types

### 3. Two API Implementations

#### a) main.py (Direct TensorFlow)
- Uses TensorFlow/Keras models directly
- Faster startup time
- Lower memory footprint
- Ideal for development and single-instance deployment
- Runs on port 8000

#### b) main-tf-serving.py (TensorFlow Serving)
- Uses TensorFlow Serving for model inference
- Better for production with high load
- Supports model versioning
- Requires separate TensorFlow Serving instance
- Runs on port 8001

## Technology Stack

- **Framework**: FastAPI
- **ML Framework**: TensorFlow 2.x, Scikit-learn
- **Image Processing**: PIL (Pillow)
- **Server**: Uvicorn (ASGI)
- **Serialization**: Joblib (for sklearn models)
- **HTTP Client**: Requests (for TF Serving)

## Project Structure

```
API Model/
├── api/
│   ├── main.py                    # Direct TensorFlow API
│   ├── main-tf-serving.py        # TF Serving client API
│   └── requirement.txt            # Python dependencies
├── Trained Model/
│   ├── 1/                        # Model version 1
│   │   ├── saved_model.pb
│   │   ├── keras_metadata.pb
│   │   ├── fingerprint.pb
│   │   └── variables/
│   └── 2/                        # Model version 2
│       └── [same structure]
├── Crop Prediction Model/
│   └── CropPredictionModel.joblib # Trained sklearn model
├── Model Data/                    # Training images (900 images)
│   ├── Train/
│   │   ├── Potato___Early_blight/ (300 images)
│   │   ├── Potato___healthy/      (300 images)
│   │   └── Potato___Late_blight/  (300 images)
│   └── Valid/
│       └── [same structure, 100 each]
├── cropYield Data/                # Crop yield datasets
│   ├── pesticides.csv
│   ├── rainfall.csv
│   ├── temp.csv
│   ├── yield_df.csv
│   └── yield.csv
├── training.ipynb                 # Disease model training notebook
├── Crop Recommendation.ipynb      # Crop recommendation training
├── Crop_recommendation.csv        # Training data for crop model
└── expotenv.yaml                  # Environment export config
```

## API Endpoints

### 1. Health Check

```http
GET /hello
```

**Response:**
```json
{
  "message": "Hello World"
}
```

### 2. Predict Crop Disease

```http
POST /predictCropDisease
Content-Type: multipart/form-data
```

**Request:**
- Body: Form-data with image file

**Response:**
```json
{
  "class": "Potato___Early_blight",
  "confidence": 0.9567
}
```

### 3. Predict Crop Recommendation

```http
POST /predictCrop
Content-Type: application/json
```

**Request Body:**
```json
{
  "n": 90,
  "p": 42,
  "k": 43,
  "temperature": 20.87,
  "humidity": 82.00,
  "ph": 6.50,
  "rainfall": 202.93
}
```

**Response:**
```json
{
  "prediction": "rice"
}
```

## Setup Instructions

### Prerequisites

- Python 3.8+
- pip
- Virtual environment (recommended)

### Installation

1. **Navigate to API directory**
   ```bash
   cd "API Model/api"
   ```

2. **Create virtual environment** (recommended)
   ```bash
   python -m venv venv
   
   # Activate on Linux/Mac
   source venv/bin/activate
   
   # Activate on Windows
   venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirement.txt
   ```

### Running the API

#### Option 1: Direct TensorFlow (main.py)

```bash
python main.py
```

The API will be available at: `http://localhost:8000`

Interactive API docs: `http://localhost:8000/docs`

#### Option 2: TensorFlow Serving (main-tf-serving.py)

1. **Start TensorFlow Serving** (requires Docker)
   ```bash
   docker run -p 8501:8501 \
     --mount type=bind,source=/path/to/Trained\ Model,target=/models/krishiVue \
     -e MODEL_NAME=krishiVue \
     -t tensorflow/serving
   ```

2. **Start API server**
   ```bash
   python main-tf-serving.py
   ```

The API will be available at: `http://localhost:8001`
