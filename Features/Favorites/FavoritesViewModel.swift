// FavoritesViewModel.swift
// Manages the user's list of favorite (liked) quotes, syncing with Supabase.

import Foundation
import Combine

/// ViewModel for managing the user's favorites (liked quotes).
final class FavoritesViewModel: ObservableObject {
    /// The user's full liked quotes (with metadata).
    @Published var likedQuotes: [LikedQuote] = []
    /// The user's current ID (must be set after login).
    var userId: UUID?
    /// Error message for UI display.
    // Replace String? errorMessage with ErrorMessage? for alert compatibility
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
            errorMessage = nil // Do not show error for empty
            return
        }
        isLoading = true
        SupabaseService.shared.fetchFullLikedQuotes(forUser: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let quotes):
                    self?.likedQuotes = quotes
                    // Only clear error if empty (first time), not on real backend error
                    if quotes.isEmpty {
                        self?.errorMessage = nil
                    }
                case .failure(let error):
                    // Only show error if the table actually exists but fails, not if just empty
                    if error.localizedDescription.contains("does not exist") {
                        self?.likedQuotes = []
                        self?.errorMessage = nil
                    } else {
                        self?.errorMessage = ErrorMessage(message: "Failed to load favorites: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    // MARK: - Remove from Favorites
    /// Removes a liked quote from the user's favorites and updates Supabase.
    func removeFromFavorites(likedQuote: LikedQuote) {
        guard let userId = userId else { return }
        SupabaseService.shared.unlikeQuote(quoteId: likedQuote.quoteId, userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.likedQuotes.removeAll { $0.quoteId == likedQuote.quoteId }
                case .failure(let error):
                    self?.errorMessage = ErrorMessage(message: "Failed to remove favorite: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Utility
    /// Checks if a given quote is in the user's favorites.
    func isFavorite(quoteId: UUID) -> Bool {
        likedQuotes.contains { $0.quoteId == quoteId }
    }
}
