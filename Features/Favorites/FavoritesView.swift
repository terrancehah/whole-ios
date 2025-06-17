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
                        ForEach(viewModel.likedQuotes, id: \.id) { quote in
                            NavigationLink(destination: EmptyView()) { // Using EmptyView as a placeholder destination
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(quote.text)
                                        .font(.body)
                                        .lineSpacing(5)
                                    Text(quote.author)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 2)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .onDelete(perform: viewModel.removeFromFavorites)
                    }
                    .listStyle(PlainListStyle()) // Use plain style for a cleaner look
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
