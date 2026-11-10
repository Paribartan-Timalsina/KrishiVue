"""KrishiVue API: potato disease classification and crop recommendation."""

from fastapi import FastAPI, File, Form, UploadFile
import uvicorn
from starlette.responses import JSONResponse
import numpy as np
from io import BytesIO
from PIL import Image, ImageOps
from typing import Optional
import tensorflow as tf
import json
import os

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'

from fastapi.middleware.cors import CORSMiddleware
import joblib
from pydantic import BaseModel

MODEL = tf.keras.models.load_model("../Trained Model/1")
CropPredictionModel = joblib.load("../Crop Prediction Model/CropPredictionModel.joblib")

CLASS_NAMES = [
    'Potato___Early_blight',
    'Potato___healthy',
    'POTATO__Late_blight'
]

# The disease model rejects any other input size.
MODEL_INPUT_SIZE = (256, 256)

# The app's detector runs on 300x300 frames, so boxes arrive in that space.
DETECTOR_INPUT_SIZE = 300

# Margin around the detector box, as a fraction of its size, so leaf edges aren't cut off.
BOX_PADDING = 0.1

app = FastAPI(title="KrishiVue Agricultural API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["*"],
)


class Package(BaseModel):
    n: float
    p: float
    k: float
    temperature: float
    humidity: float
    ph: float
    rainfall: float


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


@app.get("/hello")
async def root():
    return {"message": "Hello World"}


def read_file_as_image(data) -> Image.Image:
    image = Image.open(BytesIO(data))
    # Phones store photos sideways and record the real orientation in EXIF.
    # Apply it so the pixels match the orientation the detector box came from.
    image = ImageOps.exif_transpose(image)
    return image.convert("RGB")


class InvalidBoxError(ValueError):
    pass


def crop_to_box(image: Image.Image, box_json: str) -> Image.Image:
    """Crop to the detector box sent by the app.

    The box is JSON {"left", "top", "width", "height", "scwidth", "scheight"}
    in the detector's input space. The app squashes the whole frame (no
    cropping) to that size, so each axis scales independently.
    """
    try:
        box = json.loads(box_json)
        ref_w = float(box.get("scwidth", DETECTOR_INPUT_SIZE))
        ref_h = float(box.get("scheight", DETECTOR_INPUT_SIZE))
        left, top = float(box["left"]), float(box["top"])
        width, height = float(box["width"]), float(box["height"])
    except (ValueError, TypeError, KeyError, AttributeError) as e:
        raise InvalidBoxError(f"Invalid bounding box {box_json!r}: {e}") from e

    if ref_w <= 0 or ref_h <= 0 or width <= 0 or height <= 0:
        raise InvalidBoxError(f"Invalid bounding box {box_json!r}: non-positive size")

    scale_x = image.width / ref_w
    scale_y = image.height / ref_h
    pad_x = width * BOX_PADDING
    pad_y = height * BOX_PADDING

    # Detector boxes can extend slightly past the frame edge.
    x0 = max(0, int((left - pad_x) * scale_x))
    y0 = max(0, int((top - pad_y) * scale_y))
    x1 = min(image.width, int(round((left + width + pad_x) * scale_x)))
    y1 = min(image.height, int(round((top + height + pad_y) * scale_y)))

    if x1 - x0 < 2 or y1 - y0 < 2:
        raise InvalidBoxError(f"Bounding box {box_json!r} is outside the image")

    return image.crop((x0, y0, x1, y1))


@app.post("/predictCrop")
async def predictCrop(package: Package):
    values = [
        package.n, package.p, package.k,
        package.temperature, package.humidity,
        package.ph, package.rainfall
    ]
    prediction = CropPredictionModel.predict([values])
    return {"prediction": cropNameDict[float(prediction)]}


@app.post("/predictCropDisease")
async def predict(
    file: UploadFile = File(...),
    myString: Optional[str] = Form(None),
):
    """Classify the photo, cropped to the detector box in `myString` if one is sent."""
    try:
        image = read_file_as_image(await file.read())
        print("Image size:", image.size)

        if myString:
            image = crop_to_box(image, myString)
            print("Cropped to box:", image.size)

        image = image.resize(MODEL_INPUT_SIZE)
        img_batch = np.expand_dims(np.array(image), 0)

        prediction = MODEL.predict(img_batch)
        predicted_class = CLASS_NAMES[np.argmax(prediction[0])]
        confidence = np.max(prediction[0])

        return {
            'class': predicted_class,
            'confidence': float(confidence)
        }

    except InvalidBoxError as e:
        return JSONResponse(content={"error": str(e)}, status_code=400)

    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)


if __name__ == "__main__":
    uvicorn.run(app, host='localhost', port=8000)
