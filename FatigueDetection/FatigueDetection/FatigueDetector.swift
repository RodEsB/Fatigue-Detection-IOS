import Foundation
import AVFoundation
import UIKit
import Combine

// Estructura para leer lo que envía Python
struct ServerResponse: Codable {
    let status: String
    let probability: Double
}

class FatigueDetector: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var predictionStatus: String = "Conectando..."
    @Published var confidence: String = "--"
    @Published var shouldShowAlert: Bool = false
    

    private let serverURL = "http://192.168.0.72:5001/predict"
    
    private let captureSession = AVCaptureSession()
    private var isSending = false // Semáforo para no saturar la red
    private var lastRequestTime = Date()
    
    // Configuración de la Alarma
    private var fatigueConsecutiveCount = 0
    private let alarmThreshold = 4 // Si detecta fatiga 4 veces seguidas -> ALARMA
    
    override init() {
        super.init()
        setupCamera()
    }
    
    func setupCamera() {
        // Usamos calidad media para que la foto viaje rápido por internet
        captureSession.sessionPreset = .vga640x480
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        captureSession.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        output.alwaysDiscardsLateVideoFrames = true
        captureSession.addOutput(output)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // RATE LIMITER: Solo enviamos 1 foto cada 0.5 segundos aprox
        let now = Date()
        if isSending || now.timeIntervalSince(lastRequestTime) < 0.5 { return }
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Procesamiento de imagen en segundo plano
        DispatchQueue.global(qos: .userInteractive).async {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                let uiImage = UIImage(cgImage: cgImage)
                
                // Comprimimos a JPEG calidad 0.4 para velocidad
                if let imageData = uiImage.jpegData(compressionQuality: 0.4) {
                    let base64String = imageData.base64EncodedString()
                    self.sendToServer(base64Image: base64String)
                }
            }
        }
    }
    
    func sendToServer(base64Image: String) {
        guard let url = URL(string: serverURL) else {
            DispatchQueue.main.async { self.predictionStatus = "Error URL" }
            return
        }
        
        isSending = true
        lastRequestTime = Date()
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Cuerpo del JSON
        let body: [String: Any] = ["image": base64Image]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        // Petición de red
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer { self?.isSending = false }
            
            if let error = error {
                print("Error de red: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.predictionStatus = "Sin Conexión" }
                return
            }
            
            guard let data = data else { return }
            
            // Decodificar respuesta del servidor Python
            do {
                let result = try JSONDecoder().decode(ServerResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.handleResult(result)
                }
            } catch {
                print("Error leyendo JSON: \(error)")
            }
        }.resume()
    }
    
    private func handleResult(_ result: ServerResponse) {
        let probPercent = Int(result.probability * 100)
        
        if result.status == "fatigue" {
            fatigueConsecutiveCount += 1
            
            let displayProb = 100 - probPercent
            
            if fatigueConsecutiveCount >= alarmThreshold {
                predictionStatus = "¡ALARMA: FATIGA!"
                confidence = "\(displayProb)%"
                shouldShowAlert = true // ESTO DISPARA EL POP-UP
            } else {
                predictionStatus = "Analizando... \(fatigueConsecutiveCount)/\(alarmThreshold)"
                confidence = "\(displayProb)%"
            }
        } else {
            // EL SERVIDOR DICE QUE ESTÁ DESPIERTO
            fatigueConsecutiveCount = 0
            predictionStatus = "DESPIERTO"
            confidence = "\(probPercent)%"
        }
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspectFill
        return layer
    }
}
