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
    var color: Color = Color(hex: "#ff9f68")
    /// Optional: Custom color for the button's foreground content (icon/text).
    var foregroundColor: Color = .white
    /// Optional: Whether the button is disabled.
    var isDisabled: Bool = false

    var body: some View {
        // The ZStack ensures the content (icon/label) is always centered within the button frame,
        // even if only an icon is present and label is empty.
        Button(action: action) {
            ZStack {
                // Transparent background to expand tappable/clickable area
                RoundedRectangle(cornerRadius: 10)
                    .fill(isDisabled ? Color.gray : color)
                    .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4) // Add shadow here
                HStack(spacing: 8) {
                    if let systemImage = systemImage {
                        Image(systemName: systemImage)
                            .font(.headline)
                    }
                    // Only show label if not empty
                    if !label.isEmpty {
                        Text(label)
                            .fontWeight(.medium)
                    }
                }
                .foregroundColor(foregroundColor)
                .opacity(isDisabled ? 0.6 : 1.0)
            }
        }
        // Remove internal padding so parent .frame controls size
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
