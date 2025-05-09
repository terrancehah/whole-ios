import SwiftUI
// Ensure QuoteCategory is in scope for preview and usage

/// A dedicated view for rendering a quote as a shareable image.
struct QuoteShareCardView: View {
    let quote: Quote
    // Whether to show the watermark (false for premium users)
    var showWatermark: Bool = false
    // Whether to show share/like actions (default true for UI, false for image generation)
    var showActions: Bool = true
    // Background color for the card (default to theme background)
    var backgroundColor: Color = ThemeManager.shared.selectedTheme.theme.background
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
                    .padding(.horizontal, 24)
                if let createdBy = quote.createdBy {
                    Text("— " + createdBy.uuidString)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            // Share and Like buttons absolutely positioned just below the quote
            if showActions {
                VStack {
                    Spacer()
                    HStack(spacing: 48) {
                        Button(action: {
                            print("DEBUG: Attempting to generate share image for quote: \(quote)")
                            if let shareImage = viewModel?.generateShareImage(for: quote) {
                                print("DEBUG: Image generated? Size: \(shareImage.size)")
                                selfShareImage?(shareImage)
                            } else {
                                print("ERROR: generateShareImage returned nil")
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
                                }
                                showLikePopup?(true)
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
                    .padding(.bottom, 180) // Adjust as needed for your design
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
        // Use theme background if needed (optional, or let parent show through)
        // .background(ThemeManager.shared.selectedTheme.theme.background)
    }
}

#if DEBUG
struct QuoteShareCardView_Previews: PreviewProvider {
    static var previews: some View {
        // Use QuoteCategory enum for category (single value, not array)
        // Use UUID() for id and createdBy to resolve type mismatch errors
        QuoteShareCardView(quote: Quote(
            id: UUID(),
            englishText: "The best way to get started is to quit talking and begin doing.",
            chineseText: "开始的最好方法就是停止说话并开始行动。",
            category: QuoteCategory.motivation, // Pass a single category
            createdAt: Date(),
            createdBy: UUID()
        ), showWatermark: true)
    }
}
#endif
