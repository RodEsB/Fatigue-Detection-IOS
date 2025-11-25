import os
from flask import Flask, request, jsonify
import numpy as np
import tensorflow as tf
import cv2
import base64

app = Flask(__name__)

# CONFIGURACIÓN
#best_fatigue_model.h5
MODEL_PATH = "mobilenet_v2.h5" 
IMG_SIZE = 224

print("Construyendo arquitectura del modelo manualmente...")

try:
    base_model = tf.keras.applications.MobileNetV2(
        input_shape=(IMG_SIZE, IMG_SIZE, 3),
        include_top=False, 
        weights=None
    )

    x = base_model.output
    x = tf.keras.layers.GlobalAveragePooling2D()(x)
    
    x = tf.keras.layers.Dense(128, activation='relu', name='dense_1')(x)
    
    x = tf.keras.layers.Dropout(0.5)(x)
    
    output = tf.keras.layers.Dense(1, activation='sigmoid', name='dense_2')(x)
    
    # ENSAMBLAMOS
    model = tf.keras.models.Model(inputs=base_model.input, outputs=output)
    print("Arquitectura creada en memoria.")

    # CARGAR PESOS
    print("Inyectando pesos...")
    model.load_weights(MODEL_PATH, by_name=True, skip_mismatch=True)
    print("¡Pesos cargados exitosamente!")

except Exception as e:
    print(f"Error fatal: {e}")

@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.json
        if not data or 'image' not in data:
            return jsonify({'error': 'No image provided'}), 400

        # Decodificar
        image_data = base64.b64decode(data['image'])
        np_arr = np.frombuffer(image_data, np.uint8)
        frame = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)

        if frame is None:
            return jsonify({'error': 'Could not decode image'}), 400

        # Preprocesamiento
        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        resized = cv2.resize(frame_rgb, (IMG_SIZE, IMG_SIZE))
        normalized = (resized.astype(np.float32) / 127.5) - 1.0
        input_data = np.expand_dims(normalized, axis=0)

        # Predicción
        prediction = model.predict(input_data, verbose=0)[0][0]
        
        # Interpretación
        status = "fatigue" if prediction < 0.5 else "awake"
        prob = float(prediction)

        color = "🔴" if status == "fatigue" else "🟢"
        print(f"{color} Predicción: {status.upper()} ({prob:.4f})")
        
        return jsonify({
            'status': status,
            'probability': prob
        })

    except Exception as e:
        print(f"Error procesando imagen: {e}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    print("Servidor iniciando en puerto 5001...")
    app.run(host='0.0.0.0', port=5001, debug=False)