"""KrishiVue disease API backed by TensorFlow Serving (model 'krishiVue' on port 8501)."""

import requests
from fastapi import FastAPI, File, UploadFile
import uvicorn
import numpy as np
from io import BytesIO
from PIL import Image

endpoint = "http://localhost:8501/v1/models/krishiVue:predict"

CLASS_NAMES = [
    'Potato___Early_blight',
    'Potato___healthy',
    'POTATO__Late_blight'
]

app = FastAPI(title="KrishiVue Agricultural API (TF Serving)", version="1.0.0")


@app.get("/hello")
async def root():
    return {"message": "Hello World"}


def read_file_as_image(data) -> np.ndarray:
    return np.array(Image.open(BytesIO(data)))


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    image = read_file_as_image(await file.read())
    img_batch = np.expand_dims(image, 0)

    response = requests.post(endpoint, json={"instances": img_batch.tolist()})
    prediction = np.array(response.json()["predictions"][0])

    predicted_class = CLASS_NAMES[np.argmax(prediction)]
    confidence = np.max(prediction)

    return {
        "class": predicted_class,
        "confidence": float(confidence)
    }


if __name__ == "__main__":
    # Port 8001 so it can run alongside main.py on 8000.
    uvicorn.run(app, host='localhost', port=8001)
