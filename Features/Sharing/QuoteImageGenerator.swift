// QuoteImageGenerator.swift
// Generates quote images for sharing, adds watermark for free users.

import SwiftUI

/// Utility for generating a shareable image from a Quote.
struct QuoteImageGenerator {
    /// Generates a UIImage representation of the given quote.
    /// - Parameters:
    ///   - quote: The Quote to render.
    ///   - isPremiumUser: Whether the user is premium (if false, watermark is added)
    /// - Returns: A UIImage of the rendered quote card, or nil if rendering fails.
    static func generateShareImage(for quote: Quote, isPremiumUser: Bool) -> UIImage? {
        // Premium gating logic: if the user is not premium, show a watermark on the shared image
        // This is achieved by passing the inverse of isPremiumUser to QuoteShareCardView's showWatermark parameter
        // Use the canonical QuoteShareCardView for shareable rendering
        // If the user is not premium, showWatermark is true to add a watermark
        let controller = UIHostingController(rootView: QuoteShareCardView(quote: quote, showWatermark: !isPremiumUser))
        let view = controller.view
        // Set the desired size for the rendered image
        let targetSize = CGSize(width: 600, height: 800)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        // Use a solid white background for visibility in the share sheet
        view?.backgroundColor = UIColor.white
        // Force the layout pass so the view is fully rendered before drawing
        view?.setNeedsLayout()
        view?.layoutIfNeeded()
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
            id: UUID(),
            englishText: "The best way to get started is to quit talking and begin doing.",
            chineseText: "开始的最好方法就是停止说话并开始行动。",
            categories: [.motivation],
            createdAt: Date(),
            createdBy: UUID()
        )
        // Show both with and without watermark for preview
        VStack {
            QuoteShareCardView(quote: quote, showWatermark: true)
            QuoteShareCardView(quote: quote, showWatermark: false)
        }
    }
}
#endif
