import SwiftUI

/// A dedicated view for rendering a quote as a shareable image.
struct QuoteShareCardView: View {
    let quote: Quote
    // Whether to show the watermark (false for premium users)
    var showWatermark: Bool = false
    // Observe the global theme manager for dynamic theming
    @ObservedObject private var themeManager = ThemeManager.shared
    var viewModel: QuoteViewModel?
    var selfShareImage: ((UIImage) -> Void)?
    var showLikePopup: ((Bool) -> Void)?
    
    var body: some View {
        // Center the quote text vertically, and absolutely position the share/like buttons just below
        ZStack {
            // Centered quote text
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
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            // Share and Like buttons absolutely positioned just below the quote
            VStack {
                Spacer()
                HStack(spacing: 48) {
                    Button(action: {
                        if let shareImage = viewModel?.generateShareImage(for: quote) {
                            selfShareImage?(shareImage)
                        }
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 28, weight: .regular))
                            .foregroundColor(themeManager.selectedTheme.theme.englishColor)
                            .shadow(color: AppColors.buttonShadow, radius: 8, x: 0, y: 4)
                    }
                    Button(action: {
                        if let viewModel = viewModel {
                            if viewModel.isLiked(quote: quote) {
                                viewModel.unlike(quote: quote)
                            } else {
                                viewModel.like(quote: quote)
                                showLikePopup?(true)
                            }
                        }
                    }) {
                        Image(systemName: (viewModel?.isLiked(quote: quote) ?? false) ? "heart.fill" : "heart")
                            .font(.system(size: 28, weight: .regular))
                            .foregroundColor(themeManager.selectedTheme.theme.englishColor)
                            .shadow(color: AppColors.buttonShadow, radius: 8, x: 0, y: 4)
                            .padding(.top, 4)
                    }
                }
                .padding(.top, 24)
                // Adjust this value to control distance from quote text
                .padding(.bottom, 180) // Adjust as needed for your design
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Use theme background if needed (optional, or let parent show through)
        // .background(ThemeManager.shared.selectedTheme.theme.background)
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
