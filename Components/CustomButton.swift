// CustomButton.swift
// A reusable, customizable button component for consistent styling across the app.

import SwiftUI

/// A semantic, reusable button with configurable label, icon, and action.
struct CustomButton: View {
    /// The text label for the button.
    let label: String
    /// The system icon name (optional).
    let systemImage: String?
    /// The action to perform when the button is tapped.
    let action: () -> Void
    /// Optional: Custom color for the button.
    var color: Color = .accentColor
    /// Optional: Whether the button is disabled.
    var isDisabled: Bool = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.headline)
                }
                Text(label)
                    .fontWeight(.medium)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .foregroundColor(.white)
            .background(isDisabled ? Color.gray : color)
            .cornerRadius(10)
            .opacity(isDisabled ? 0.6 : 1.0)
        }
        .disabled(isDisabled)
    }
}

// MARK: - Preview
struct CustomButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CustomButton(label: "Like", systemImage: "heart.fill", action: {})
            CustomButton(label: "Share", systemImage: "square.and.arrow.up", action: {}, color: .blue)
            CustomButton(label: "Disabled", systemImage: nil, action: {}, isDisabled: true)
        }
        .padding()
        .background(Color(.systemBackground))
        .previewLayout(.sizeThatFits)
    }
}
