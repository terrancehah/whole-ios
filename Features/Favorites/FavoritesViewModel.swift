// FavoritesViewModel.swift
// Manages the user's list of favorite (liked) quotes, syncing with Supabase.

import Foundation
import Combine

/// ViewModel for managing the user's favorites (liked quotes).
final class FavoritesViewModel: ObservableObject {
    /// The user's full liked quotes.
    @Published var likedQuotes: [Quote] = []
    /// The user's current ID.
    var userId: UUID?
    /// Error message for UI display.
    @Published var errorMessage: ErrorMessage?
    /// Loading state for UI feedback.
    @Published var isLoading: Bool = false
    /// Combine cancellables.
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Fetch Liked Quotes
    /// Loads all liked quotes for the current user from Supabase.
    func fetchLikedQuotes() {
        guard let userId = userId else {
            likedQuotes = []
            errorMessage = nil
            return
        }
        isLoading = true
        SupabaseService.shared.fetchFullLikedQuotes(forUser: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let quotes):
                    self?.likedQuotes = quotes
                    if quotes.isEmpty {
                        self?.errorMessage = nil
                    }
                case .failure(let error):
                    self?.errorMessage = ErrorMessage(message: "Failed to load favorites: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Remove from Favorites
    /// Removes a liked quote from the user's favorites and updates Supabase.
    func removeFromFavorites(at offsets: IndexSet) {
        guard let userId = userId else { return }
        let quotesToRemove = offsets.map { self.likedQuotes[$0] }
        
        // Remove from the local array first for instant UI update.
        self.likedQuotes.remove(atOffsets: offsets)
        
        // Then, call the backend to remove each one.
        for quote in quotesToRemove {
            SupabaseService.shared.unlikeQuote(quoteId: quote.id, userId: userId) { [weak self] result in
                DispatchQueue.main.async {
                    if case .failure(let error) = result {
                        // If the backend call fails, you might want to handle the error,
                        // e.g., by re-inserting the quote into the local array and showing an alert.
                        self?.errorMessage = ErrorMessage(message: "Failed to remove favorite: \(error.localizedDescription)")
                        // For simplicity, we'll just log the error for now.
                        print("Error removing favorite from backend: \(error)")
                    }
                }
            }
        }
    }

    // MARK: - Utility
    /// Checks if a given quote is in the user's favorites.
    func isFavorite(quoteId: UUID) -> Bool {
        likedQuotes.contains { $0.id == quoteId }
    }
}
