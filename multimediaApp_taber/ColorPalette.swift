import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

extension Color {
    // Helper para modo claro y oscuro interactuando con UIKit en caso de estar disponible (iOS)
    private static func dynamicColor(light: Color, dark: Color) -> Color {
        #if canImport(UIKit)
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
        #else
        return light
        #endif
    }
    
    // Paleta con nombres originales, adaptada para modo Claro (Tan/Brown original) y Oscuro (Invertido/Dark Brown)
    static let aliceBlue      = dynamicColor(light: Color(red: 0.96, green: 0.95, blue: 0.92),
                                             dark: Color(red: 0.11, green: 0.08, blue: 0.06)) // Fondo principal
    static let icyBlue        = dynamicColor(light: Color(red: 0.91, green: 0.87, blue: 0.83),
                                             dark: Color(red: 0.16, green: 0.12, blue: 0.10)) // Fondo secundario
    static let skyBlue        = dynamicColor(light: Color(red: 0.84, green: 0.79, blue: 0.72),
                                             dark: Color(red: 0.22, green: 0.16, blue: 0.13))
    static let coolSky        = dynamicColor(light: Color(red: 0.78, green: 0.67, blue: 0.57),
                                             dark: Color(red: 0.30, green: 0.22, blue: 0.18))
    static let coolSky2       = dynamicColor(light: Color(red: 0.70, green: 0.59, blue: 0.49),
                                             dark: Color(red: 0.40, green: 0.30, blue: 0.24))
    static let dodgerBlue     = dynamicColor(light: Color(red: 0.66, green: 0.53, blue: 0.43),
                                             dark: Color(red: 0.50, green: 0.38, blue: 0.31))
    static let brilliantAzure = dynamicColor(light: Color(red: 0.56, green: 0.42, blue: 0.32),
                                             dark: Color(red: 0.60, green: 0.48, blue: 0.40))
    static let twitterBlue    = dynamicColor(light: Color(red: 0.49, green: 0.35, blue: 0.27),
                                             dark: Color(red: 0.72, green: 0.61, blue: 0.53))
    static let oceanDeep      = dynamicColor(light: Color(red: 0.39, green: 0.27, blue: 0.21),
                                             dark: Color(red: 0.85, green: 0.76, blue: 0.69))
    static let cobaltBlue     = dynamicColor(light: Color(red: 0.29, green: 0.20, blue: 0.16),
                                             dark: Color(red: 0.96, green: 0.95, blue: 0.92)) // Texto principal
}
