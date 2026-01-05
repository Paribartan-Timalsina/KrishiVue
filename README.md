# KrishiVue - AI-powered Plant and Disease Detection

## Description

KrishiVue is a mobile application designed for plant leaf detection and disease classification using Convolutional Neural Networks (CNN). The application assists farmers in identifying crop diseases efficiently through real-time camera feeds and image uploads. The backend is powered by **FastAPI**, ensuring fast and scalable API development, while the mobile application is developed using **Flutter** for cross-platform compatibility.

## Features

- **Real-time plant disease detection** using camera feeds.
- **Image upload support** for disease classification.
- **Pre-trained models** like **SSD MobileNetV2** and **ResNet** for high accuracy.
- **Detailed disease diagnosis** to help farmers make informed decisions.

## Tech Stack

- **Frontend**: Flutter
- **Backend**: FastAPI
- **Machine Learning Models**: TensorFlow, SSD MobileNetV2, ResNet
- **Web Framework**: FastAPI
- **API Server**: Uvicorn (ASGI)
- **Others**: Python, TensorFlow

## Installation & Execution

### 1. Clone the Repository

Clone the project repository and navigate to the project folder:

```sh
git clone https://github.com/Paribartan-Timalsina/KrishiVue.git
cd krishivue
```

### 2. Install Dependencies

Install the required dependencies for the backend:

```sh
pip install -r requirements.txt
```

### 3. Run the Backend Server

Start the FastAPI backend server using Uvicorn:

```sh
uvicorn main:app --reload
```

### 4. Run the Mobile Application

Navigate to the Flutter project directory and run the mobile application:

```sh
flutter run
```



