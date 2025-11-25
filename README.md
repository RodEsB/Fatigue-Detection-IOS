# 🚗 Driver Fatigue Detection System (iOS + Deep Learning)

![iOS](https://img.shields.io/badge/iOS-16.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.0-orange)
![Python](https://img.shields.io/badge/Python-3.11-yellow)
![TensorFlow](https://img.shields.io/badge/TensorFlow-Keras-red)
![OpenCV](https://img.shields.io/badge/OpenCV-Vision-green)

> **Official Repository:** [https://github.com/RodEsB/Fatigue-Detection-IOS](https://github.com/RodEsB/Fatigue-Detection-IOS)

This project implements a complete **Computer Vision** system aimed at road safety. It utilizes a **Client-Server** architecture where an iOS application captures and preprocesses real-time video frames, while a Python server executes a Deep Learning model (**MobileNetV2**) to classify the driver's state.

---

## 🧠 Overview & Architecture

The system relies on a strict computer vision processing pipeline to ensure high accuracy and minimize false positives.

### System Flow
1.  **Acquisition (iOS):** Frame capture using `AVFoundation`.
2.  **Preprocessing & Compression:** Vision transformation and bit-rate encoding for efficient transmission.
3.  **Secure Transport:** SSL tunneling via **Ngrok** to the inference server.
4.  **Vision Pipeline (Python):** Decoding, Normalization, and ROI extraction.
5.  **Inference (Deep Learning):** Binary classification (Fatigue vs. Awake) using MobileNetV2.
6.  **Decision Policy:** Temporal persistence algorithm to trigger alarms.

---

## 🔬 Methodology & Image Processing

The core of this project is not just the model, but the **signal processing** applied before inference. Classical vision techniques and ablation studies were conducted to determine the optimal flow.

### 1. Preprocessing Pipeline
To ensure the model generalizes correctly, images undergo the following stages:

* **ROI Detection (Region of Interest):** Validates the presence of a face to avoid processing background noise.
* **Data Normalization:**
    * Tensor scaling to `[-1, 1]` ranges (Specific to MobileNetV2).
    * Bicubic resizing to `224x224` px.
* **Color Transformations:** Color space conversion from BGR (OpenCV) to RGB (TensorFlow).



[Image of image preprocessing pipeline]


### 2. Filter Exploration (Classical Vision)
During the research phase, various filters were evaluated to highlight facial features (eyes/mouth):
* **Edge Detection (Canny Filter):** Evaluated to highlight the geometry of closed vs. open eyes.
* **Illumination Studies:** Histogram adjustments to compensate for low-light conditions inside the vehicle cabin.

---

## 🧪 Ablation Studies & Experimental Validation

A rigorous **Ablation Study** was conducted to demonstrate the contribution of each system component. Modules were systematically deactivated to measure their impact on performance.

### Experimental Design
Three main scenarios were compared using a dataset with **Ground Truth** (manually annotated real labels):

| Experiment | Configuration | Observation |
| :--- | :--- | :--- |
| **A (Baseline)** | Raw Image -> Model | High error rate with lighting variations. |
| **B (Preproc)** | Face Crop + Normalization | Significant improvement in accuracy. |
| **C (Full Pipeline)** | Preproc + Temporal Filter (Persistence) | **Drastic reduction of False Positives.** |

### Data Validation Strategy
To prevent *overfitting* and ensure statistical robustness:

1.  **Holdout Method:** Strict data separation into:
    * Training (70%)
    * Validation (15%)
    * Testing (15%)
2.  **K-Fold Cross Validation:** Cross-validation (K=5) was used to verify that the model did not memorize specific data, yielding a stable average accuracy.
3.  **Evaluation Metrics:**
    * **Accuracy:** Global average of correct predictions.
    * **Min Average Precision:** Worst-case evaluation to ensure safety.
    * **Confusion Matrix:** Analysis of False Negatives (the most critical error in road safety).

---

## 🤖 Deep Learning: MobileNetV2

The **MobileNetV2** architecture was selected due to its efficiency in the *Accuracy/Latency* trade-off for real-time applications.

* **Transfer Learning:** Pre-trained weights on ImageNet were used, followed by *Fine-Tuning* on the upper dense layers.
* **Custom Top Layers:**
    * `GlobalAveragePooling2D`
    * `Dense (128, ReLU)`
    * `Dropout (0.5)` (To prevent overfitting)
    * `Dense (1, Sigmoid)` (Probabilistic output 0-1)



[Image of MobileNetV2 architecture]


---

## 🛠️ Installation & Usage

### Prerequisites
* **Server:** Python 3.9+, TensorFlow 2.x, Flask, OpenCV.
* **Client:** iPhone with iOS 16.0+, Xcode 14+.
* **Network:** Ngrok (to expose localhost).

### 1. Backend Setup (Python)
```bash
# Clone repository
git clone [https://github.com/RodEsB/Fatigue-Detection-IOS.git](https://github.com/RodEsB/Fatigue-Detection-IOS.git)
cd Server

# Create virtual environment and install dependencies
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Start the server
python3 server.py
````

### 2\. Connection Tunnel

In a new terminal window:

```bash
ngrok http 5001
# Copy the generated URL (e.g., [https://xyz.ngrok-free.app](https://xyz.ngrok-free.app))
```

### 3\. Client Configuration (iOS)

1.  Open `FatigueDetection.xcodeproj` in Xcode.
2.  Navigate to the `FatigueDetector.swift` file.
3.  Replace the `serverURL` variable with your Ngrok link.
4.  Compile and run on a physical device (required for camera access).

-----

## 📊 Results

The final system demonstrates a robust capability to distinguish drowsiness states from alert states, validated through system tests with averaged accuracy metrics. The implementation of the preprocessing pipeline proved fundamental in stabilizing the vision input for the neural model.

-----

### Credits

Developed by **Rodrigo Espíritu Berra** for the Computer Vision Final Project.
