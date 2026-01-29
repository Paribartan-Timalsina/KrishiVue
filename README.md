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


# KrishiVue - Smart Agriculture Mobile App

KrishiVue is a Flutter-based mobile application for agricultural disease detection and crop recommendations using machine learning and computer vision.

## Features

### 1. Real-Time Plant Disease Detection
- Live camera feed with object detection using TensorFlow Lite
- Detects multiple plants in real-time
- Bounding box visualization with confidence scores

### 2. Image-Based Detection
- Upload images from gallery for disease analysis
- Supports batch image processing
- Detailed detection results with confidence levels

### 3. Crop Recommendation System
- AI-powered crop recommendations based on:
  - Soil nutrients (N, P, K)
  - Temperature
  - Humidity
  - pH levels
  - Rainfall data
- Integration with backend API

### 4. User-Friendly Interface
- Intuitive splash screen and onboarding
- Bottom navigation for easy access
- About and Contact pages
- Clean, modern design

## Technology Stack

- **Framework**: Flutter 3.0+
- **Language**: Dart
- **ML Model**: TensorFlow Lite
- **Camera**: camera ^0.10.5
- **Image Processing**: image ^4.0.17
- **HTTP Requests**: http ^1.1.0
- **State Management**: Flutter StatefulWidget

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── recognition.dart      # Recognition result model
│   └── screen_params.dart    # Screen parameters
├── pages/                    # UI screens
│   ├── intro.dart           # Splash screen
│   ├── landing.dart         # Main landing page
│   ├── camerapage.dart      # Camera interface
│   ├── detection.dart       # Detection results
│   ├── prediction.dart      # Crop prediction
│   ├── previewpage.dart     # Image preview
│   ├── previewgallery.dart  # Gallery preview
│   ├── about.dart           # About page
│   └── contact.dart         # Contact page
├── ui/                      # UI components
│   ├── home_view.dart       # Home view wrapper
│   ├── detector_widget.dart # Object detector widget
│   ├── box_widget.dart      # Bounding box widget
│   └── stats_widget.dart    # Stats display widget
├── widgets/                 # Reusable widgets
│   ├── app_bar.dart         # Custom app bar
│   ├── bottomnavbar.dart    # Bottom navigation
│   └── nav_drawer.dart      # Navigation drawer
├── service/                 # Services
│   └── detector_service.dart # ML detection service
└── utils/                   # Utilities
    └── image_utils.dart     # Image processing utilities

assets/
├── models/
│   ├── final.tflite         # TFLite object detection model
│   └── labelmap.txt         # Model labels
├── images/
│   └── tfl_logo.png         # TensorFlow logo
├── back.jpg                 # Background image
└── logo.png                 # App logo
```

## Setup Instructions

### Prerequisites

- Flutter SDK (>=3.0.0 <4.0.0)
- Dart SDK
- Android Studio / VS Code
- Android SDK (for Android) or Xcode (for iOS)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd KrishiVue/krishivue
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Backend API**
   - Update API endpoints in relevant files
   - Ensure backend server is running (see API Model README)

4. **Run the app**
   ```bash
   # For Android
   flutter run

   # For iOS
   flutter run -d ios

   # For a specific device
   flutter devices
   flutter run -d <device-id>
   ```

## ML Model Information

### Object Detection Model
- **Model**: final.tflite
- **Type**: SSD MobileNet-based object detection
- **Input Size**: 300x300 pixels
- **Classes**: Plant diseases (as defined in labelmap.txt)
- **Confidence Threshold**: 0.4 (40%)

### Model Performance
- **Inference Time**: ~50-200ms (device dependent)
- **Pre-processing Time**: ~20-50ms
- **Total Prediction Time**: ~100-300ms
- **Platform**: Optimized with XNNPACK delegate on Android

## Configuration

### Camera Settings
- Default orientation: Portrait
- Uses device's rear camera for detection
- Supports live camera feed and gallery images

### Detection Parameters
Modify these in `detector_service.dart`:
```dart
static const int mlModelInputSize = 300;  // Model input size
static const double confidence = 0.4;      // Confidence threshold
```

## Dependencies

```yaml
dependencies:
  flutter: sdk
  cupertino_icons: ^1.0.5
  tflite_flutter: ^0.10.1      # TFLite runtime
  camera: ^0.10.5+5            # Camera access
  path_provider: ^2.0.15       # File paths
  path: ^1.8.3                 # Path utilities
  image_picker: ^1.0.0         # Image selection
  http: ^1.1.0                 # HTTP requests
  image: ^4.0.17               # Image processing
  tflite_v2: ^1.0.0            # Additional TFLite support
  exif: ^3.1.4                 # EXIF data handling
```

## Troubleshooting

### Common Issues

1. **Model not loading**
   - Ensure `final.tflite` and `labelmap.txt` exist in `assets/models/`
   - Check `pubspec.yaml` includes assets directory

2. **Camera permission denied**
   - Add camera permissions to AndroidManifest.xml (Android)
   - Add camera usage description to Info.plist (iOS)

3. **Slow inference**
   - Reduce input image size
   - Ensure hardware acceleration is enabled
   - Test on physical device (emulators are slower)

4. **Build errors**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## API Integration

The app communicates with a FastAPI backend for:
- Crop disease prediction
- Crop recommendation based on soil parameters

API endpoints should be configured in the respective service files.
---

**Note**: This app requires a backend API server for full functionality. See the API Model README for backend setup instructions.


