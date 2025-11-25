import cv2
import numpy as np
from tensorflow.keras.models import load_model
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input

# --- Constants and Parameters ---
MODEL_PATH = "mobilenet_v2.h5" 

IMG_HEIGHT = 224
IMG_WIDTH = 224
PREDICTION_THRESHOLD = 0.5 

# --- CONSTANTES PARA LA POLÍTICA DE DETECCIÓN (Persistencia) ---
ALARM_TRIGGER_FRAMES = 10  
fatigue_consecutive_frames = 0 

# --- Visualization Parameters ---
FONT = cv2.FONT_HERSHEY_SIMPLEX
TEXT_COLOR_AWAKE = (0, 255, 0)  
TEXT_COLOR_WARNING = (0, 165, 255) 
TEXT_COLOR_FATIGUE = (0, 0, 255)  
TEXT_POSITION = (50, 50)
TEXT_SIZE = 1.0

# --- Load Resources ---
print("Cargando modelo MobileNetV2...")
try:
    model = load_model(MODEL_PATH)
    print(f"Modelo cargado exitosamente.")
except Exception as e:
    print(f"Error cargando el modelo: {e}")
    exit()

# Haar Cascade
face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')

# Initialize Webcam 
cap = cv2.VideoCapture(0)
if not cap.isOpened():
    print("Error: No se puede abrir la webcam.")
    exit()

print("Iniciando... Presiona 'q' para salir.")

while True:
    ret, frame = cap.read()
    if not ret: break
    
    display_frame = frame.copy()
    
    # Detección de rostro
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(60, 60))
    
    model_input_img = None
    
    if len(faces) > 0:
        (x, y, w, h) = sorted(faces, key=lambda f: f[2]*f[3], reverse=True)[0]
        
        cv2.rectangle(display_frame, (x, y), (x+w, y+h), (255, 255, 0), 2)
        
        # RECORTAR ROI
        face_roi = frame[y:y+h, x:x+w]
        
        try:
            # PRE-PROCESAMIENTO
            face_rgb = cv2.cvtColor(face_roi, cv2.COLOR_BGR2RGB)
            # Resize
            processed_frame = cv2.resize(face_rgb, (IMG_WIDTH, IMG_HEIGHT))
            # Preprocess input
            img_array = preprocess_input(processed_frame.astype(np.float32))
            # Expandir dimensiones
            model_input_img = np.expand_dims(img_array, axis=0)
            
            # Visualización debug
            debug_frame = processed_frame.copy()
            
        except Exception as e:
            print("Error procesando ROI:", e)
            model_input_img = None
    else:
        cv2.putText(display_frame, "NO FACE", (50, 100), FONT, 1, (0, 255, 255), 2)
        debug_frame = np.zeros((IMG_HEIGHT, IMG_WIDTH, 3), dtype=np.uint8)

    if 'debug_frame' in locals():
        debug_show = cv2.cvtColor(debug_frame, cv2.COLOR_RGB2BGR) if len(faces) > 0 else debug_frame
        cv2.imshow('MobileNet Input', debug_show)

    # Lógica de predicción
    if model_input_img is not None:
        try:
            prediction = model.predict(model_input_img, verbose=0)[0][0]
            
            if prediction < PREDICTION_THRESHOLD: 
                # Detección de fatiga
                fatigue_consecutive_frames += 1
                
                if fatigue_consecutive_frames >= ALARM_TRIGGER_FRAMES:
                    fatigue_prob = (1 - prediction) * 100
                    status = f"ALARM: FATIGUE ({fatigue_prob:.0f}%)"
                    color = TEXT_COLOR_FATIGUE
                else:
                    status = f"WARNING... {fatigue_consecutive_frames}/{ALARM_TRIGGER_FRAMES}"
                    color = TEXT_COLOR_WARNING
            else:
                fatigue_consecutive_frames = 0
                status = f"AWAKE ({prediction*100:.0f}%)"
                color = TEXT_COLOR_AWAKE
            
        except Exception as e:
            print(f"Error en predicción: {e}")
            status = "ERROR"
            color = (0, 255, 255)
            
        cv2.putText(display_frame, status, TEXT_POSITION, FONT, 0.8, color, 2, cv2.LINE_AA)

    cv2.imshow('Driver Drowsiness Detection (MobileNetV2)', display_frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()