// QuoteImageGenerator.swift
// Generates quote images for sharing, adds watermark for free users.

import SwiftUI

/// Utility for generating a shareable image from a Quote.
struct QuoteImageGenerator {
    /// Generates a UIImage representation of the given quote.
    /// - Parameters:
    ///   - quote: The Quote to render.
    ///   - isPremiumUser: Whether the user is premium (if false, watermark is added)
    ///   - backgroundColor: The background color of the share image
    /// - Returns: A UIImage of the rendered quote card, or nil if rendering fails.
    static func generateShareImage(for quote: Quote, isPremiumUser: Bool, backgroundColor: Color) -> UIImage? {
        print("DEBUG: Entered generateShareImage. Quote: \(quote), isPremiumUser: \(isPremiumUser)")
        // Premium gating logic: if the user is not premium, show a watermark on the shared image
        // This is achieved by passing the inverse of isPremiumUser to QuoteShareCardView's showWatermark parameter
        // Use the canonical QuoteShareCardView for shareable rendering
        // If the user is not premium, showWatermark is true to add a watermark
        // Pass the background color to the share card
        let controller = UIHostingController(rootView: QuoteShareCardView(quote: quote, showWatermark: !isPremiumUser, showActions: false, backgroundColor: backgroundColor))
        guard let view = controller.view else {
            print("ERROR: controller.view is nil")
            return nil
        }
        // Set the desired size for the rendered image
        let targetSize = CGSize(width: 600, height: 800)
        view.bounds = CGRect(origin: .zero, size: targetSize)
        // Use the provided background color for share image background
        view.backgroundColor = backgroundColor.toUIColor()
        // Attach to a temporary UIWindow to ensure full rendering
        let window = UIWindow(frame: CGRect(origin: .zero, size: targetSize))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        // Force the view to load and layout
        _ = controller.view // Ensure the view is loaded
        view.setNeedsLayout()
        view.layoutIfNeeded()
        // Let the runloop process layout and rendering
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
        // Render the view hierarchy to an image
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let image = renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        // Clean up the window
        window.isHidden = true
        print("DEBUG: Returning image with size \(image.size)")
        return image
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
