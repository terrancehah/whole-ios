// QuoteImageGenerator.swift
// Generates quote images for sharing, adds watermark for free users.

import SwiftUI
import Features

/// Utility for generating a shareable image from a Quote.
struct QuoteImageGenerator {
    /// Generates a UIImage representation of the given quote.
    /// - Parameters:
    ///   - quote: The Quote to render.
    ///   - isPremiumUser: Whether the user is premium (if false, watermark is added)
    /// - Returns: A UIImage of the rendered quote card, or nil if rendering fails.
    static func generateShareImage(for quote: Quote, isPremiumUser: Bool) -> UIImage? {
        // Use the canonical QuoteShareCardView for shareable rendering, with watermark overlay if needed.
        let controller = UIHostingController(rootView: Features.Quotes.QuoteShareCardView(quote: quote, showWatermark: !isPremiumUser))
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
        // Use QuoteCategory enum for categories
        let quote = Quote(
            id: "1",
            englishText: "The best way to get started is to quit talking and begin doing.",
            chineseText: "开始的最好方法就是停止说话并开始行动。",
            categories: [.motivation],
            createdAt: Date(),
            createdBy: "Walt Disney"
        )
        // Show both with and without watermark for preview
        VStack {
            Features.Quotes.QuoteShareCardView(quote: quote, showWatermark: true)
            Features.Quotes.QuoteShareCardView(quote: quote, showWatermark: false)
        }
    }
}
#endif
