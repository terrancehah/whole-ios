// FavoritesView.swift
// Displays user's saved (liked) quotes in a clean, minimal list.

import SwiftUI

/// Main UI for displaying the user's favorite (liked) quotes.
struct FavoritesView: View {
    @ObservedObject var viewModel: FavoritesViewModel

    var body: some View {
        NavigationView {
            Group {
                // Display loading indicator while data is being fetched
                if viewModel.isLoading {
                    ProgressView("Loading favorites...")
                        .bodyFont(size: 16) // Use body font for loading text
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } 
                // Display list of liked quotes if data is available
                else if !viewModel.likedQuotes.isEmpty {
                    List {
                        ForEach(viewModel.likedQuotes) { likedQuote in
                            VStack(alignment: .leading, spacing: 8) {
                                // Display quote ID with heading font
                                Text("Quote ID: \(likedQuote.quoteId)")
                                    .headingFont(size: 18) // Use heading font for quote id
                                // Display timestamp with caption font
                                Text("Liked at: \(likedQuote.createdAt.formatted())")
                                    .captionFont(size: 13) // Use caption font for timestamp
                                    .foregroundColor(.secondary)
                            }
                            .swipeActions(edge: .trailing) {
                                // Button to remove quote from favorites
                                Button(role: .destructive) {
                                    viewModel.removeFromFavorites(likedQuote: likedQuote)
                                } label: {
                                    Label("Remove", systemImage: "heart.slash")
                                        .bodyFont(size: 15)
                                }
                            }
                        }
                    }
                } 
                // Display empty state if no quotes are liked
                else {
                    VStack(spacing: 16) {
                        Image(systemName: "heart")
                            .font(.system(size: 48))
                            .foregroundColor(.pink)
                        // Display heading text with heading font
                        Text("No favorites yet")
                            .headingFont(size: 20)
                            .foregroundColor(ThemeManager.shared.selectedTheme.theme.englishColor)
                        // Display body text with body font
                        Text("Tap the heart icon on any quote to add it to your favorites.")
                            .bodyFont(size: 15)
                            .multilineTextAlignment(.center)
                            .foregroundColor(ThemeManager.shared.selectedTheme.theme.chineseColor)
                    }
                    .padding()
                }
            }
            // Set navigation title (cannot apply custom font directly)
            .navigationTitle("Favorites")
            .alert(item: $viewModel.errorMessage) { error in
                // Use standard Text for title/message (font cannot be customized in native Alert)
                Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
            }
        }
    }
}

// MARK: - Preview
struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = FavoritesViewModel()
        vm.likedQuotes = [] // Empty state for preview
        return FavoritesView(viewModel: vm)
    }
}

// ErrorMessage struct for Identifiable error alerts
struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}
