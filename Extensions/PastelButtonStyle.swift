// PastelButtonStyle.swift
// Custom SwiftUI ButtonStyle for onboarding, using Serene Minimalism theme colors.
// Applies warm backgrounds, rounded corners, and semantic font for primary and secondary actions.

import SwiftUI

/// A semantic button style for primary actions (e.g., Continue, Install Widget, Start Free Trial)
struct WarmPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .bodyFont(size: 17, weight: .semibold)
            .foregroundColor(.white)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "#ff9f68")) // Serene Minimalism accent color
            .cornerRadius(14)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
            .padding(.horizontal, 24) // Standard margin on both sides
    }
}

/// A semantic button style for secondary actions (e.g., Skip, Later)
struct WarmSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .bodyFont(size: 17, weight: .regular)
            .foregroundColor(.white)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "#ff784f")) // Serene Minimalism secondary color
            .cornerRadius(14)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1)
            .padding(.horizontal, 24) // Standard margin on both sides
    }
}
