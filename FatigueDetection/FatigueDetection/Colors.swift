//
//  Colors.swift
//  AplicacionEmociones
//
//  Created by Rod Espiritu Berra on 24/11/25.
//
import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.hasPrefix("#") ? hex.index(after: hex.startIndex) : hex.startIndex
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue >> 20) & 0xFF) / 255.0
        let g = Double((rgbValue >> 12) & 0xFF) / 255.0
        let b = Double(rgbValue & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}
