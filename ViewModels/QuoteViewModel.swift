// QuoteViewModel.swift
// Handles fetching, storing, and managing the state of quotes for the UI.

import Foundation
import Combine

/// ViewModel to manage fetching and state of quotes from Supabase.
final class QuoteViewModel: ObservableObject {
    /// Published array of quotes for use in the UI.
    @Published var quotes: [Quote] = []
    /// Published property to track loading state.
    @Published var isLoading: Bool = false
    /// Published property for error messages.
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    /// Fetch quotes from Supabase using the SupabaseService.
    func fetchQuotes() {
        isLoading = true
        errorMessage = nil
        SupabaseService.shared.fetchQuotes { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let quotes):
                    self?.quotes = quotes
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
