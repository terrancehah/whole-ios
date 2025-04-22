// View+Extensions.swift
// Add custom SwiftUI view modifiers and reusable view helpers here.

import SwiftUI

/// Semantic font modifiers for app-wide typography consistency.
extension View {
    /// Applies the Baskerville font for headings (with fallback to system serif).
    func headingFont(size: CGFloat = 24, weight: Font.Weight = .bold) -> some View {
        self.font(Font.custom("Baskerville", size: size).weight(weight))
    }
    /// Applies the SF Compact font for body text (with fallback to system font).
    func bodyFont(size: CGFloat = 16, weight: Font.Weight = .regular) -> some View {
        self.font(Font.custom("SF Compact", size: size).weight(weight))
    }
    /// Applies the SF Compact font for captions or footnotes.
    func captionFont(size: CGFloat = 13, weight: Font.Weight = .regular) -> some View {
        self.font(Font.custom("SF Compact", size: size).weight(weight))
    }
}
