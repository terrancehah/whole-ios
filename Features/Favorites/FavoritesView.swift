// FavoritesView.swift
// Displays user's saved (liked) quotes in a clean, minimal list.

import SwiftUI

/// Main UI for displaying the user's favorite (liked) quotes.
struct FavoritesView: View {
    @ObservedObject var viewModel: FavoritesViewModel

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading favorites...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if !viewModel.likedQuotes.isEmpty {
                    List {
                        ForEach(viewModel.likedQuotes) { likedQuote in
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Quote ID: \(likedQuote.quoteId)")
                                    .font(.headline)
                                Text("Liked at: \(likedQuote.createdAt.formatted())")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.removeFromFavorites(likedQuote: likedQuote)
                                } label: {
                                    Label("Remove", systemImage: "heart.slash")
                                }
                            }
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "heart")
                            .font(.system(size: 48))
                            .foregroundColor(.pink)
                        Text("No favorites yet")
                            .font(ThemeManager.shared.selectedTheme.theme.englishFont)
                            .foregroundColor(ThemeManager.shared.selectedTheme.theme.englishColor)
                        Text("Tap the heart icon on any quote to add it to your favorites.")
                            .font(ThemeManager.shared.selectedTheme.theme.chineseFont)
                            .multilineTextAlignment(.center)
                            .foregroundColor(ThemeManager.shared.selectedTheme.theme.chineseColor)
                    }
                    .padding()
                }
            }
            .navigationTitle("Favorites")
            .alert(item: $viewModel.errorMessage) { error in
                Alert(title: Text("Error"), message: Text(error), dismissButton: .default(Text("OK")))
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
