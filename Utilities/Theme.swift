// Theme.swift
// Defines color schemes, fonts, and appearance for the app.

import SwiftUI

/// Centralized semantic color definitions for the Whole app.
struct AppColors {
    // MARK: - Core Backgrounds
    static let background = Color(hex: "#ffeedf") // Main background (Serene Minimalism)
    static let card = Color(hex: "#FFFFFF")       // Card background
    static let groupedBackground = Color(.systemGroupedBackground) // For grouped forms
    
    // MARK: - Text
    static let primaryText = Color(hex: "#2D3748")
    static let secondaryText = Color.secondary // Use SwiftUI's semantic color
    static let monochromeText = Color.black
    static let pastelPrimaryText = Color(hex: "#2D3748")
    static let pastelSecondaryText = Color(hex: "#C9D1D9")
    
    // MARK: - Accents & UI
    static let accent = Color(hex: "#ff9f68")
    static let accentSecondary = Color(hex: "#ff784f")
    static let pastelAccent = Color(hex: "#F7FAFC")
    static let error = Color.red
    static let purpleHighlight = Color.purple.opacity(0.08)
    static let systemGray5 = Color(.systemGray5)
    static let systemGray4 = Color(.systemGray4)
    
    // MARK: - Shadows
    static let buttonShadow = Color.black.opacity(0.18)
    static let cardShadow = Color.black.opacity(0.09)
    static let monoShadow = Color.black.opacity(0.12)
    static let pastelShadow = Color.gray.opacity(0.10)
}

// MARK: - Color Helper for UIKit Interop
extension Color {

    /// Convert SwiftUI Color to UIColor for UIKit usage
    func toUIColor() -> UIColor {
        let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            let r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
            let g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
            let b = CGFloat(hexNumber & 0x0000ff) / 255
            return UIColor(red: r, green: g, blue: b, alpha: 1)
        }
        return UIColor(self)
    }
}

// MARK: - Usage Example (in ThemeManager.swift)
// Theme(background: AppColors.background, cardBackground: AppColors.card, ...)
