// QuoteCardView.swift
// Displays a bilingual quote card with Like and Share actions.

import SwiftUI

/// A card view for displaying a single quote with English and Chinese text, and action buttons.
struct QuoteCardView: View {
    /// The quote to display.
    let quote: Quote
    /// Callback for Like button tap.
    var onLike: (() -> Void)? = nil
    /// Callback for Share button tap.
    var onShare: (() -> Void)? = nil
    /// Whether the quote is already liked (for UI state).
    var isLiked: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // English text
            Text(quote.englishText)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)

            // Chinese translation
            Text(quote.chineseText)
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)

            // Categories (optional, shown as chips)
            if !quote.categories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(quote.categories, id: \ .self) { category in
                            Text(category)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.15))
                                .foregroundColor(.accentColor)
                                .cornerRadius(8)
                        }
                    }
                }
            }

            // Action buttons
            HStack(spacing: 16) {
                CustomButton(label: isLiked ? "Liked" : "Like", systemImage: isLiked ? "heart.fill" : "heart", action: {
                    onLike?()
                }, color: isLiked ? .red : .accentColor)

                CustomButton(label: "Share", systemImage: "square.and.arrow.up", action: {
                    onShare?()
                }, color: .blue)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

// MARK: - Preview
struct QuoteCardView_Previews: PreviewProvider {
    static var previews: some View {
        QuoteCardView(
            quote: Quote(
                id: "1",
                englishText: "The best time to plant a tree was 20 years ago. The second best time is now.",
                chineseText: "种一棵树最好的时间是二十年前，其次是现在。",
                categories: ["Inspiration", "Time"],
                createdAt: nil,
                createdBy: nil
            ),
            onLike: {},
            onShare: {},
            isLiked: false
        )
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.light)
        QuoteCardView(
            quote: Quote(
                id: "2",
                englishText: "Success is not final, failure is not fatal: It is the courage to continue that counts.",
                chineseText: "成功不是终点，失败也不是终结，重要的是继续前进的勇气。",
                categories: ["Success", "Courage"],
                createdAt: nil,
                createdBy: nil
            ),
            onLike: {},
            onShare: {},
            isLiked: true
        )
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
    }
}
