//
//  About.swift
//  AplicacionEmociones
//
//  Created by Rod Espiritu Berra on 24/11/25.
//
import SwiftUI

struct SecondView: View {
    var body: some View {
        ScrollView{
            ZStack {
                Rectangle()
                    .foregroundColor(Color(hex: "1ABC9C"))
                    .ignoresSafeArea()
                
                VStack{
                    Text("¿De qué trata esta aplicación?")
                            .font(.system(size: 32))
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(.top, 5)
                            .padding(.bottom, 50)
                            .frame(maxWidth: .infinity, alignment: .center)
                    
                    DisclosureGroup{
                        Text(
                            "Esta aplicación detecta el estado actual del conductor, revisa cuando el conductor esté despierto o que esté mostrando señales de fatiga, en dado caso que no se encuentre en la mejor situación el conductor, será notificado y recomendado a que tome un descanso, todo con la finalidad de tener una mejor seguridad vial."
                        )
                        .padding()
                        .foregroundColor(.white)
                        .background(Color(hex: "0A3981").opacity(0.8))
                        .cornerRadius(10)
                    } label: {
                        Text("Propósito")
                            .font(.system(size: 28, weight: .bold))
                    }
                    .accentColor(.white)
                    .padding(.bottom, 20)
                        
                    DisclosureGroup {
                        VStack(alignment: .leading, spacing: 15) {
                            Text(
                                "Desarrollo en Swift para la aplicación móvil y SwiftUI para la interfaz de usuario"
                            )
                            .foregroundColor(.white)
                            Text("Python para entrenar el modelo de inteligencia artificial.")
                                .foregroundColor(.white)
                            Text(
                                "Flask como servidor para comunicar la app con el modelo de CNN + LSTM previamente entrenado."
                            )
                            .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color(hex: "0A3981").opacity(0.8))
                        .cornerRadius(10)
                    } label:{
                        Text("Características")
                            .font(.system(size: 28, weight: .bold))
                    }
                    .accentColor(.white)
                    .padding(.bottom, 20)
                                        
                    DisclosureGroup {
                        VStack(alignment: .leading, spacing: 15) {
                            Text(
                                "La cámara de la aplicación captura una foto cada segundo y la envía al servidor. Allí, el modelo de inteligencia artificial previamente entrenado evalúa la imagen para identificar si el conductor se encuentra con fatiga, una vez identificado en dado caso que presente señales de fatiga será notificado y recomendado a que tome un descanso."
                            )
                        }
                        .padding()
                        .background(Color(hex: "0A3981").opacity(0.8))
                        .cornerRadius(10)
                    } label:{
                        Text("Cómo funciona")
                            .font(.system(size: 28, weight: .bold))
                    }
                    .accentColor(.white)
                    .padding(.bottom, 20)
                                        
                    DisclosureGroup {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("La app está desarrollada en Swift con interfaz en SwiftUI. El modelo de IA fue entrenado en Python, utilizando un dataset de más de 25,000 imagenes, fue evaluado previamente contra otros modelos entrenados de la misma manera y finalmente se utilizó el modelo CNN + LSTM debido a su precisión, finalmente el modelo es ejecutado en un servidor de Flask para la comunicación del modelo con la app.")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color(hex: "0A3981").opacity(0.8))
                        .cornerRadius(10)
                    } label:{
                        Text("Información Técnica")
                            .font(.system(size: 28, weight: .bold))
                    }
                    .accentColor(.white)
                    .padding(.bottom, 20)
                                        
                    DisclosureGroup {
                        VStack(alignment: .leading, spacing: 15) {
                            Text(
                                "Esta aplicación fue desarrollada por Rodrigo Espíritu Berra"
                            )
                            .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color(hex: "0A3981").opacity(0.8))
                        .cornerRadius(10)
                    } label:{
                        Text("Créditos")
                            .font(.system(size: 28, weight: .bold))
                    }
                    .accentColor(.white)
                                        
                    Spacer()
                }
                .padding()
            }
        }
        .background(Color(hex: "1ABC9C"))
    }
}
#Preview {
    ContentView()
}
