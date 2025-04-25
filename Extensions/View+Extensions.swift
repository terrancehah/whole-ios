// View+Extensions.swift
// Add custom SwiftUI view modifiers and reusable view helpers here.

import SwiftUI

// Centralized app font sizes for headings, body, and captions
struct AppFont {
    static let heading: CGFloat = 32
    static let body: CGFloat = 20
    static let caption: CGFloat = 16
}

/// Semantic font modifiers for app-wide typography consistency.
extension View {
    /// Applies the Baskerville font for headings (with fallback to system serif).
    func headingFont(size: CGFloat = AppFont.heading) -> some View {
        self.font(Font.custom("Baskerville", size: size))
    }
    /// Applies the Baskerville font for body text (with fallback to system serif).
    func bodyFont(size: CGFloat = AppFont.body) -> some View {
        self.font(Font.custom("Baskerville", size: size))
    }
    /// Applies the Baskerville font for captions or footnotes.
    func captionFont(size: CGFloat = AppFont.caption) -> some View {
        self.font(Font.custom("Baskerville", size: size))
    }
}
