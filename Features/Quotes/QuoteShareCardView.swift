import SwiftUI

/// A dedicated view for rendering a quote as a shareable image.
struct QuoteShareCardView: View {
    let quote: Quote
    // Whether to show the watermark (false for premium users)
    var showWatermark: Bool = false
    // Observe the global theme manager for dynamic theming
    @ObservedObject private var themeManager = ThemeManager.shared
    var body: some View {
        // No card, no shadow, just text centered on the screen with same background as RootAppView
        VStack(spacing: 20) {
            Text(quote.englishText)
                .font(themeManager.selectedTheme.theme.englishFont)
                .foregroundColor(themeManager.selectedTheme.theme.englishColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Text(quote.chineseText)
                .font(themeManager.selectedTheme.theme.chineseFont)
                .foregroundColor(themeManager.selectedTheme.theme.chineseColor)
                .multilineTextAlignment(.center)
            if let createdBy = quote.createdBy {
                Text("— " + createdBy.uuidString)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
            // Watermark overlay for free users
            if showWatermark {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.yellow)
                    Text("Whole")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .shadow(radius: 3)
                }
                .padding(10)
                .background(Color.black.opacity(0.35))
                .cornerRadius(10)
                .padding(.top, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#ffeedf")) // Match RootAppView background
    }
}

#if DEBUG
struct QuoteShareCardView_Previews: PreviewProvider {
    static var previews: some View {
        // Use QuoteCategory enum for categories
        // Use UUID() for id and createdBy to resolve type mismatch errors
        QuoteShareCardView(quote: Quote(
            id: UUID(),
            englishText: "The best way to get started is to quit talking and begin doing.",
            chineseText: "开始的最好方法就是停止说话并开始行动。",
            categories: [.motivation],
            createdAt: Date(),
            createdBy: UUID()
        ), showWatermark: true)
    }
}
#endif
