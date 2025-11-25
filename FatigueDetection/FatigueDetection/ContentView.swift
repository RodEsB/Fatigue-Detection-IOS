//
//  ContentView.swift
//  AplicacionEmociones
//
//  Created by Rod Espiritu Berra on 24/11/25.
//

import SwiftUI

struct ContentView: View {
    @State var presentSheet: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background image with opacity and blur
                ZStack {
                    Image("fondo")
                        .resizable()
                        .scaledToFill()
                        .blur(radius: 4) // Increase the blur radius for better effect
                        .ignoresSafeArea()
                        .opacity(0.4) // Adjusting the opacity
                }
                
                VStack {
                    Spacer()
                    Text("Detección de fatiga")
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(40)
                        .shadow(color: .black, radius: 3, x: 1, y: 2)
                    
                    Button {
                        presentSheet = true
                    } label: {
                        VStack {
                            ZStack{
                                Image(systemName: "face.smiling")
                                    .scaleEffect(0.5)
                            }
                            .scaleEffect(3)
                            .padding()
                            Text("Iniciar la cámara ")
                        }
                    }
                    .padding()
                    .font(.system(size: 28))
                    .fontWeight(.bold)
                    .frame(width: 300, height: 120)
                    .background(Color(hex:"1ABC9C"))
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    
                    NavigationLink(destination: SecondView()) {
                        Text("¿Cómo funciona la app?")
                            .padding()
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .frame(width: 300, height: 60)
                            .background(Color(hex:"1ABC9C"))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    
                    Spacer()
                }
            }
            .sheet(isPresented: $presentSheet) {
                CameraView(presentSheet: $presentSheet)
            }
        }
    }
}

#Preview {
    ContentView()
}
