import cv2
import numpy as np
from tensorflow.keras.models import load_model
import time 

#Constants and Parameters
MODEL_PATH = "best_fatigue_model.h5"
SEQ_LENGTH = 20
IMG_HEIGHT = 64
IMG_WIDTH = 64
PREDICTION_THRESHOLD = 0.5 

ALARM_TRIGGER_FRAMES = 5 
fatigue_consecutive_frames = 0

frame_buffer = []

# Visualization Parameters
FONT = cv2.FONT_HERSHEY_SIMPLEX
TEXT_COLOR_AWAKE = (0, 255, 0)    
TEXT_COLOR_WARNING = (0, 165, 255) 
TEXT_COLOR_FATIGUE = (0, 0, 255) 
TEXT_POSITION = (50, 50)
TEXT_SIZE = 1.0

# Load Resources 
print("Loading model...")
try:
    model = load_model(MODEL_PATH)
    print(f"Model loaded.")
except Exception as e:
    print(f"Error loading model: {e}")
    exit()

# Haar Cascade
face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')

# Initialize Webcam 
cap = cv2.VideoCapture(0)
if not cap.isOpened():
    print("Error: Could not open webcam.")
    exit()

print("Starting... Press 'q' to quit.")

while True:
    ret, frame = cap.read()
    if not ret: break
    
    display_frame = frame.copy()
    
    # Convertir a escala de grises para la detección de rostro
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    
    # Detectar rostros
    faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))
    
    # Variable para guardar la imagen que irá al modelo
    model_input_img = None
    
    if len(faces) > 0:
        # Si encontramos rostros
        (x, y, w, h) = sorted(faces, key=lambda f: f[2]*f[3], reverse=True)[0]
    
        cv2.rectangle(display_frame, (x, y), (x+w, y+h), (255, 255, 0), 2)
        
        #(Region of Interest - ROI)
        face_roi = frame[y:y+h, x:x+w]
        
        try:
            processed_frame_display = cv2.resize(face_roi, (IMG_WIDTH, IMG_HEIGHT))
            model_input_img = processed_frame_display / 255.0
            
            # Visualización para debug
            debug_frame = processed_frame_display.copy()
            
        except Exception as e:
            print("Error resizing face crop:", e)
            model_input_img = None
    else:
        cv2.putText(display_frame, "NO FACE DETECTED", (50, 100), FONT, 1, (0, 255, 255), 2)
        debug_frame = np.zeros((64, 64, 3), dtype=np.uint8)
        frame_buffer = [] 

    # Mostrar la ventana de lo que ve el modelo
    if 'debug_frame' in locals():
        cv2.resizeWindow('Model Input (64x64)', 200, 200) 
        cv2.imshow('Model Input (64x64)', debug_frame)

    # Lógica de predicción
    if model_input_img is not None:
        frame_buffer.append(model_input_img)
        
        if len(frame_buffer) > SEQ_LENGTH:
            frame_buffer.pop(0)
            
        if len(frame_buffer) == SEQ_LENGTH:
            try:
                input_sequence = np.array(frame_buffer)
                input_sequence = np.expand_dims(input_sequence, axis=0)
                

                prediction = model.predict(input_sequence, verbose=0)[0][0]
                
                if prediction > PREDICTION_THRESHOLD:
                    # El modelo cree que hay fatiga, aumentamos el contador de persistencia
                    fatigue_consecutive_frames += 1
                    
                    # Verificamos si se cumple la política (persistencia temporal)
                    if fatigue_consecutive_frames >= ALARM_TRIGGER_FRAMES:
                        status = f"ALARM: FATIGUE ({prediction*100:.1f}%)"
                        color = TEXT_COLOR_FATIGUE
                    else:
                        # Estado intermedio: Detecta fatiga pero aún no activa alarma
                        status = f"WARNING... ({fatigue_consecutive_frames}/{ALARM_TRIGGER_FRAMES})"
                        color = TEXT_COLOR_WARNING
                else:
                    # El conductor parece despierto, reiniciamos el contador
                    fatigue_consecutive_frames = 0
                    status = f"AWAKE ({prediction*100:.1f}%)"
                    color = TEXT_COLOR_AWAKE
                    
            except Exception as e:
                status = "ERROR"
                color = (0, 255, 255)
        else:
            status = f"BUFFERING... ({len(frame_buffer)}/{SEQ_LENGTH})"
            color = (255, 255, 0)
            
        cv2.putText(display_frame, status, TEXT_POSITION, FONT, TEXT_SIZE, color, 2, cv2.LINE_AA)

    cv2.imshow('Fatigue Detection', display_frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()