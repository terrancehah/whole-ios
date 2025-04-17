import SwiftUI

/// A dedicated view for rendering a quote as a shareable image.
struct QuoteShareCardView: View {
    let quote: Quote
    // Observe the global theme manager for dynamic theming
    @ObservedObject private var themeManager = ThemeManager.shared
    var body: some View {
        ZStack {
            // Use the current theme's card background and shadow
            RoundedRectangle(cornerRadius: 32)
                .fill(themeManager.selectedTheme.theme.cardBackground)
                .shadow(color: themeManager.selectedTheme.theme.shadow, radius: 12)
            VStack(spacing: 20) {
                // English quote text styled per theme
                Text(quote.englishText)
                    .font(themeManager.selectedTheme.theme.englishFont)
                    .foregroundColor(themeManager.selectedTheme.theme.englishColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                // Chinese quote text styled per theme
                Text(quote.chineseText)
                    .font(themeManager.selectedTheme.theme.chineseFont)
                    .foregroundColor(themeManager.selectedTheme.theme.chineseColor)
                    .multilineTextAlignment(.center)
                if let createdBy = quote.createdBy {
                    Text("— " + createdBy)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
            }
            .padding(32)
        }
        .frame(width: 600, height: 800)
        .background(themeManager.selectedTheme.theme.background)
    }
}

#if DEBUG
struct QuoteShareCardView_Previews: PreviewProvider {
    static var previews: some View {
        QuoteShareCardView(quote: Quote(
            id: "1",
            englishText: "The best way to get started is to quit talking and begin doing.",
            chineseText: "开始的最好方法就是停止说话并开始行动。",
            categories: ["Motivation"],
            createdAt: Date(),
            createdBy: "Walt Disney"
        ))
    }
}
#endif
