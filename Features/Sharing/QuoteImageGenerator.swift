// QuoteImageGenerator.swift
// Generates quote images for sharing, adds watermark for free users.

import SwiftUI
import Features

/// Utility for generating a shareable image from a Quote.
struct QuoteImageGenerator {
    /// Generates a UIImage representation of the given quote.
    /// - Parameter quote: The Quote to render.
    /// - Returns: A UIImage of the rendered quote card, or nil if rendering fails.
    static func generateShareImage(for quote: Quote) -> UIImage? {
        // Use the canonical QuoteShareCardView for shareable rendering.
        let controller = UIHostingController(rootView: Features.Quotes.QuoteShareCardView(quote: quote))
        let view = controller.view
        // Set the desired size for the rendered image
        let targetSize = CGSize(width: 600, height: 800)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        // Render the view hierarchy to an image
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: view?.bounds ?? CGRect.zero, afterScreenUpdates: true)
        }
    }
}

#if DEBUG
struct QuoteImageGenerator_Previews: PreviewProvider {
    static var previews: some View {
        let quote = Quote(
            id: "1",
            englishText: "The best way to get started is to quit talking and begin doing.",
            chineseText: "开始的最好方法就是停止说话并开始行动。",
            categories: ["Motivation"],
            createdAt: Date(),
            createdBy: "Walt Disney"
        )
        return Features.Quotes.QuoteShareCardView(quote: quote)
    }
}
#endif
