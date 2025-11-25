import SwiftUI
import AVFoundation

struct CameraView: View {
    @Binding var presentSheet: Bool
    
    // Inicializamos el detector que creamos arriba
    @StateObject private var detector = FatigueDetector()

    var body: some View {
        ZStack {
            // Capa de Video
            CameraPreview(detector: detector)
                .ignoresSafeArea()
            
            // Capa de Información (Texto sobrepuesto)
            VStack {
                // Botón de cerrar (X)
                HStack {
                    Spacer()
                    Button(action: {
                        presentSheet = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                    }
                    .padding()
                }
                
                Spacer()
                
                // Panel de Estado
                VStack(spacing: 5) {
                    Text(detector.predictionStatus)
                        .font(.system(size: 26, weight: .black))
                        .foregroundColor(getStatusColor(status: detector.predictionStatus))
                        .shadow(color: .black, radius: 1)
                    
                    Text("Probabilidad: \(detector.confidence)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.6)) // Fondo semitransparente
                .cornerRadius(15)
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
            }
        }
        // CONFIGURACIÓN DEL POP-UP DE ALERTA
        .alert("⚠️ PELIGRO DETECTADO", isPresented: $detector.shouldShowAlert) {
            Button("Detener Alarma", role: .cancel) {
            }
            Button("Llamar Contacto", role: .destructive) {
                // Lógica pendiente
            }
        } message: {
            Text("Se han detectado signos persistentes de fatiga. Por favor detén el vehículo y toma un descanso.")
        }
    }
    
    // Función auxiliar para cambiar el color del texto
    func getStatusColor(status: String) -> Color {
        if status.contains("ALARMA") { return .red }
        if status.contains("Analizando") { return .orange }
        if status.contains("Conectando") { return .gray }
        return .green
    }
}

// Wrapper de UIKit para mostrar la cámara en SwiftUI
struct CameraPreview: UIViewRepresentable {
    @ObservedObject var detector: FatigueDetector
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = detector.getPreviewLayer()
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
