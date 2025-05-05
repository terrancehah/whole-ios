// ThemeManager.swift
// Centralized theme management for Whole app.

import SwiftUI

/// Enum representing available app themes.
enum AppTheme: String, CaseIterable, Identifiable {
    case sereneMinimalism
    case elegantMonochrome
    case softPastelElegance
    
    var id: String { rawValue }
    
    /// Display name for UI
    var displayName: String {
        switch self {
        case .sereneMinimalism: return "Serene Minimalism"
        case .elegantMonochrome: return "Elegant Monochrome"
        case .softPastelElegance: return "Soft Pastel Elegance"
        }
    }
}

/// Observable theme manager for global theme state.
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    @Published var selectedTheme: AppTheme = .sereneMinimalism
    private init() {}
}

/// Struct holding theme colors, fonts, and other style info.
struct Theme {
    let background: Color
    let cardBackground: Color
    let englishFont: Font
    let englishColor: Color
    let chineseFont: Font
    let chineseColor: Color
    let shadow: Color
    // Add more as needed (button, accent, etc.)
}

/// Returns the Theme for the given AppTheme.
extension AppTheme {
    var theme: Theme {
        switch self {
        case .sereneMinimalism:
            // Updated to use centralized AppColors
            return Theme(
                background: AppColors.background,
                cardBackground: AppColors.card,
                englishFont: .system(size: 20, weight: .regular, design: .serif),
                englishColor: AppColors.primaryText,
                chineseFont: .system(size: 18, weight: .regular, design: .default),
                chineseColor: AppColors.primaryText,
                shadow: AppColors.cardShadow
            )
        case .elegantMonochrome:
            return Theme(
                background: Color.white,
                cardBackground: .white,
                englishFont: .system(size: 22, weight: .bold, design: .default),
                englishColor: AppColors.monochromeText,
                chineseFont: .system(size: 18, weight: .regular, design: .default),
                chineseColor: AppColors.monochromeText,
                shadow: AppColors.monoShadow
            )
        case .softPastelElegance:
            return Theme(
                background: AppColors.pastelAccent,
                cardBackground: AppColors.pastelAccent,
                englishFont: .custom("Lora", size: 20),
                englishColor: AppColors.pastelPrimaryText,
                chineseFont: .custom("Source Han Sans", size: 18),
                chineseColor: AppColors.pastelSecondaryText,
                shadow: AppColors.pastelShadow
            )
        }
    }
}

/// Helper to create Color from hex.
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
