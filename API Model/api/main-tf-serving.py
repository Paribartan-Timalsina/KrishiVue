"""
KrishiVue FastAPI Backend - TensorFlow Serving Client

This API acts as a client to TensorFlow Serving for crop disease detection.
This approach is better for production deployments with high load as it:
- Supports model versioning
- Enables horizontal scaling
- Provides better performance optimization
- Allows GPU acceleration

Requires: TensorFlow Serving running on port 8501

Author: KrishiVue Team
"""

import requests
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

# ============================================================================
# CONFIGURATION
# ============================================================================

# TensorFlow Serving endpoint URL
# The model should be served using: docker run -p 8501:8501 tensorflow/serving
endpoint = "http://localhost:8501/v1/models/krishiVue:predict"

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
    title="KrishiVue Agricultural API (TF Serving)",
    description="FastAPI client for TensorFlow Serving - Crop disease detection",
    version="1.0.0"
)

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


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    """
    Detect plant disease from uploaded image using TensorFlow Serving
    
    This endpoint acts as a proxy to TensorFlow Serving, which hosts the
    actual ML model. This separation allows for better scalability and
    model management in production environments.
    
    Args:
        file: Uploaded image file (JPG/PNG)
        
    Returns:
        dict: {
            "class": "disease_name",
            "confidence": 0.95
        }
        
    Example:
        POST /predict
        Files: {"file": <image_data>}
        Response: {"class": "Potato___Early_blight", "confidence": 0.9567}
        
    Note:
        Requires TensorFlow Serving to be running on localhost:8501
        with model name 'krishiVue'
    """
    # Read and convert uploaded image to numpy array
    image = read_file_as_image(await file.read())
    
    # Add batch dimension for model input [1, height, width, channels]
    img_batch = np.expand_dims(image, 0)

    # Prepare request payload for TensorFlow Serving
    # Format: {"instances": [[image_data]]}
    json_data = {
        "instances": img_batch.tolist()
    }

    # Send prediction request to TensorFlow Serving
    response = requests.post(endpoint, json=(json_data))
    
    # Extract prediction results from TF Serving response
    prediction = np.array(response.json()["predictions"][0])

    # Get predicted class and confidence score
    predicted_class = CLASS_NAMES[np.argmax(prediction)]
    confidence = np.max(prediction)

    return {
        "class": predicted_class,
        "confidence": float(confidence)
    }


# ============================================================================
# SERVER STARTUP
# ============================================================================

if __name__ == "__main__":
    # Run the API server on localhost:8001
    # Note: Different port (8001) to avoid conflict with main.py (8000)
    # For production, use a proper ASGI server like Gunicorn
    uvicorn.run(app, host='localhost', port=8001)
