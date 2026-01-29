"""
KrishiVue FastAPI Backend - Agricultural ML API Server

This API provides two main services:
1. Crop Disease Detection - Identifies potato plant diseases from images
2. Crop Recommendation - Suggests optimal crops based on soil and environmental parameters

Author: KrishiVue Team
"""

from fastapi import FastAPI, File, UploadFile
import uvicorn
from starlette.responses import JSONResponse
import numpy as np
from io import BytesIO
from PIL import Image
import tensorflow as tf
import os

# Suppress TensorFlow logging (only show errors)
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'

import requests
from fastapi.middleware.cors import CORSMiddleware
import joblib
from pydantic import BaseModel
import json

# ============================================================================
# MODEL INITIALIZATION
# ============================================================================

# Load TensorFlow model for crop disease detection (potato diseases)
MODEL = tf.keras.models.load_model("../Trained Model/1")

# Load scikit-learn model for crop recommendation
CropPredictionModel = joblib.load("../Crop Prediction Model/CropPredictionModel.joblib")

# Disease classification labels for potato plant diseases
CLASS_NAMES = [
    'Potato___Early_blight',   # Early blight fungal disease
    'Potato___healthy',         # Healthy potato plant
    'POTATO__Late_blight'       # Late blight fungal disease
]

# ============================================================================
# FASTAPI APP INITIALIZATION
# ============================================================================

app = FastAPI(
    title="KrishiVue Agricultural API",
    description="ML-powered API for crop disease detection and crop recommendations",
    version="1.0.0"
)

# Configure CORS to allow frontend applications to access the API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # Frontend origin (modify for production)
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["*"],
)

# ============================================================================
# DATA MODELS (Request/Response Schemas)
# ============================================================================

class UserInput(BaseModel):
    """Simple user input model (currently unused)"""
    user_input: float

class Package(BaseModel):
    """
    Input model for crop recommendation
    
    Attributes:
        n: Nitrogen content in soil (ratio)
        p: Phosphorus content in soil (ratio)
        k: Potassium content in soil (ratio)
        temperature: Average temperature in Celsius
        humidity: Relative humidity percentage
        ph: Soil pH level (0-14 scale)
        rainfall: Average rainfall in mm
    """
    n: float
    p: float
    k: float
    temperature: float	
    humidity: float	
    ph: float	
    rainfall: float

# Mapping from model output (0-21) to crop names
cropNameDict = {
    0: 'apple',
    1: 'banana',
    2: 'blackgram',
    3: 'chickpea',
    4: 'coconut',
    5: 'coffee',
    6: 'cotton',
    7: 'grapes',
    8: 'jute',
    9: 'kidneybeans',
    10: 'lentil',
    11: 'maize',
    12: 'mango',
    13: 'mothbeans',
    14: 'mungbean',
    15: 'muskmelon',
    16: 'orange',
    17: 'papaya',
    18: 'pigeonpeas',
    19: 'pomegranate',
    20: 'rice',
    21: 'watermelon'
}

# ============================================================================
# API ENDPOINTS
# ============================================================================

@app.get("/hello")
async def root():
    """
    Health check endpoint
    
    Returns:
        dict: Simple greeting message to verify API is running
    """
    return {"message": "Hello World"}


def read_file_as_image(data) -> np.ndarray:
    """
    Convert uploaded file bytes to numpy array image
    
    Args:
        data: Raw bytes from uploaded file
        
    Returns:
        np.ndarray: Image as numpy array in RGB format
    """
    image = np.array(Image.open(BytesIO(data)))
    return image


@app.post("/predictCrop")
async def predictCrop(package: Package):
    """
    Predict the best crop to plant based on soil and environmental conditions
    
    Uses a machine learning classifier trained on agricultural data to recommend
    the most suitable crop from 22 different crop types.
    
    Args:
        package: Package object containing N, P, K, temperature, humidity, pH, rainfall
        
    Returns:
        dict: {"prediction": "crop_name"} - Recommended crop name
        
    Example:
        POST /predictCrop
        {
            "n": 90, "p": 42, "k": 43,
            "temperature": 20.87, "humidity": 82.00,
            "ph": 6.50, "rainfall": 202.93
        }
        Response: {"prediction": "rice"}
    """
    # Prepare input features as array
    values = [
        package.n, package.p, package.k, 
        package.temperature, package.humidity, 
        package.ph, package.rainfall
    ]
    reshaped_values = [values]
    
    # Get prediction from model (returns crop index 0-21)
    prediction = CropPredictionModel.predict(reshaped_values)
    
    # Map index to crop name
    return {"prediction": cropNameDict[float(prediction)]}


@app.post("/predictCropDisease")
async def predict(file: UploadFile = File(...)):
    """
    Detect plant disease from uploaded image
    
    Uses a CNN model to classify potato plant diseases. Currently supports:
    - Early blight detection
    - Late blight detection
    - Healthy plant identification
    
    Args:
        file: Uploaded image file (JPG/PNG)
        
    Returns:
        dict: {
            "class": "disease_name",
            "confidence": 0.95
        }
        
    Raises:
        500 error if image processing or prediction fails
        
    Example:
        POST /predictCropDisease
        Files: {"file": <image_data>}
        Response: {"class": "Potato___Early_blight", "confidence": 0.9567}
    """
    try:
        # Read and convert uploaded image to numpy array
        image = read_file_as_image(await file.read())
        print("Image shape:", image.shape)

        # Add batch dimension for model input [1, height, width, channels]
        img_batch = np.expand_dims(image, 0)
        print("Batch shape:", img_batch.shape)

        # Get prediction from TensorFlow model
        prediction = MODEL.predict(img_batch)
        
        # Extract predicted class and confidence
        predicted_class = CLASS_NAMES[np.argmax(prediction[0])]
        confidence = np.max(prediction[0])
        
        return {
            'class': predicted_class,
            'confidence': float(confidence)
        }

    except Exception as e:
        # Return error message if prediction fails
        return JSONResponse(
            content={"error": str(e)}, 
            status_code=500
        )


# ============================================================================
# SERVER STARTUP
# ============================================================================

if __name__ == "__main__":
    # Run the API server on localhost:8000
    # For production, use a proper ASGI server like Gunicorn
    uvicorn.run(app, host='localhost', port=8000)
