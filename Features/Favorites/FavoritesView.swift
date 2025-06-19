// FavoritesView.swift
// Displays user's saved (liked) quotes in a clean, minimal list.

import SwiftUI

/// Main UI for displaying the user's favorite (liked) quotes.
struct FavoritesView: View {
    @ObservedObject var viewModel: FavoritesViewModel
    @Environment(\.editMode) private var editMode // State for list edit mode

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
                            FavoriteRowView(quote: quote)
                                .listRowSeparator(.hidden) // Remove horizontal lines
                                .listRowInsets(EdgeInsets()) // Make card span full width of the row
                        }
                        .onDelete(perform: viewModel.removeFromFavorites)
                    }
                    .listStyle(PlainListStyle()) // Use plain style for a cleaner look
                    .padding(.horizontal, 8) // Reduced horizontal padding for wider cards
                    .environment(\.editMode, editMode) // Pass editMode to the list
                    .animation(.default, value: viewModel.likedQuotes) // Animate list changes
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
            .navigationTitle("Favorites") // Apply to the Group
            .toolbar { // Apply to the Group
                if !viewModel.likedQuotes.isEmpty && !viewModel.isLoading {
                    EditButton()
                }
            }
            .alert(item: $viewModel.errorMessage) { errorMsg in // Display error alert if an error occurs
                Alert(title: Text("Error"), message: Text(errorMsg.message), dismissButton: .default(Text("OK")))
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

// MARK: - Favorite Row View
/// A view that represents a single row in the favorites list.
struct FavoriteRowView: View {
    let quote: Quote

    var body: some View {
        VStack(alignment: .leading, spacing: 12) { // Adjusted spacing
            Text(quote.englishText)
                .font(.title2) // Font from QuoteCardView
                // .fontWeight(.semibold) // Removed to use default (regular) weight for a lighter appearance
                .lineSpacing(5)
                .foregroundColor(AppColors.primaryText)

            Text(quote.chineseText)
                .font(.title3) // Font from QuoteCardView
                .lineSpacing(4)
                .foregroundColor(AppColors.secondaryText)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        // .frame(minHeight: 150, alignment: .topLeading) // Removed to allow natural height based on content
        .background(AppColors.background)
        .cornerRadius(12)
        .shadow(color: AppColors.pastelShadow, radius: 3, x: 0, y: 2)
    }
}
