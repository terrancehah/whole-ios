// QuoteViewModel.swift
// Handles quote data fetching, swipe logic, like/share, and daily limits.

import Foundation
import Combine
import SwiftUI

/// ViewModel for managing the state and actions for quote browsing.
final class QuoteViewModel: ObservableObject {
    // MARK: - Published Properties
    /// The list of quotes loaded for the user.
    @Published var quotes: [Quote] = []
    /// Set of quote IDs that have been liked by the user.
    @Published var likedQuoteIDs: Set<UUID> = [] // Changed from Set<String> to Set<UUID> for type safety
    /// Error message for UI display.
    @Published var errorMessage: String? = nil
    /// Whether to show the paywall CTA.
    @Published var showPaywallCTA: Bool = false

    // MARK: - User & Subscription
    /// The current user profile.
    var user: UserProfile?
    /// The user's subscription status (free, trial, monthly, yearly).
    var subscription: Subscription?
    /// Whether the user is on a free plan (no trial, no active sub).
    var isFreeUser: Bool {
        guard let subscription = subscription else { return true }
        return subscription.status == "free"
    }
    /// The max number of quotes a free user can swipe per day.
    let swipeLimit: Int = 10
    /// Whether the swipe limit has been reached.
    var reachedSwipeLimit: Bool {
        isFreeUser && quotes.count >= swipeLimit
    }
    /// Whether the user can like more quotes (within limit).
    var canLike: Bool {
        !reachedSwipeLimit
    }

    // MARK: - Combine
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(user: UserProfile? = nil, subscription: Subscription? = nil) {
        self.user = user
        self.subscription = subscription
        fetchQuotes()
        fetchLikedQuotes()
    }

    // MARK: - Data Fetching
    /// Fetches quotes from Supabase or local cache.
    func fetchQuotes() {
        // Call the SupabaseService to fetch quotes from the backend.
        SupabaseService.shared.fetchQuotes { [weak self] result in
            // Ensure UI updates happen on the main thread.
            DispatchQueue.main.async {
                switch result {
                case .success(let quotes):
                    // Assign the fetched quotes to the published property.
                    self?.quotes = quotes
                case .failure(let error):
                    // Set the error message for UI display.
                    self?.errorMessage = "Failed to load quotes: \(error.localizedDescription)"
                }
            }
        }
    }

    /// Fetches liked quote IDs from Supabase for the user.
    func fetchLikedQuotes() {
        // Ensure we have a valid user ID before fetching liked quotes.
        guard let userId = user?.id else {
            // If no user is logged in, clear likedQuoteIDs.
            self.likedQuoteIDs = []
            return
        }
        // Fetch liked quote IDs from Supabase.
        SupabaseService.shared.fetchLikedQuoteIDs(forUser: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let ids):
                    // Update the likedQuoteIDs set with fetched IDs.
                    self?.likedQuoteIDs = Set(ids)
                case .failure(let error):
                    // Optionally, set an error message for the UI.
                    self?.errorMessage = "Failed to fetch liked quotes: \(error.localizedDescription)"
                }
            }
        }
    }

    /// Retry fetching quotes after an error.
    func retryFetchQuotes() {
        errorMessage = nil
        fetchQuotes()
    }

    // MARK: - Actions
    /// Like a quote and sync with backend.
    func like(quote: Quote) {
        // Optimistically update the local likedQuoteIDs set for instant UI feedback.
        likedQuoteIDs.insert(quote.id)
        // Ensure we have a valid user ID before syncing with backend.
        guard let userId = user?.id else { return }
        // Sync the like with Supabase.
        SupabaseService.shared.likeQuote(quoteId: quote.id, userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Like was successfully saved to backend; nothing further needed.
                    break
                case .failure(let error):
                    // On failure, revert the local change and show an error message.
                    self?.likedQuoteIDs.remove(quote.id)
                    self?.errorMessage = "Failed to like quote: \(error.localizedDescription)"
                }
            }
        }
    }

    /// Unlike a quote and sync with backend.
    func unlike(quote: Quote) {
        // Optimistically remove the quote ID for instant UI feedback.
        likedQuoteIDs.remove(quote.id)
        // Ensure we have a valid user ID before syncing with backend.
        guard let userId = user?.id else { return }
        // Sync the unlike with Supabase.
        SupabaseService.shared.unlikeQuote(quoteId: quote.id, userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Unlike was successfully saved to backend; nothing further needed.
                    break
                case .failure(let error):
                    // On failure, revert the local change and show an error message.
                    self?.likedQuoteIDs.insert(quote.id)
                    self?.errorMessage = "Failed to unlike quote: \(error.localizedDescription)"
                }
            }
        }
    }

    /// Checks if a quote is liked by the user.
    func isLiked(quote: Quote) -> Bool {
        likedQuoteIDs.contains(quote.id)
    }

    /// Generates a shareable image for the quote.
    func generateShareImage(for quote: Quote) -> UIImage? {
        // Delegate image generation to the QuoteImageGenerator utility for maintainability and reuse.
        // Pass isPremiumUser based on the user's subscription status.
        return QuoteImageGenerator.generateShareImage(for: quote, isPremiumUser: !isFreeUser)
    }

    /// Saves the currently displayed quote to App Group UserDefaults for widget access.
    /// This keeps the widget in sync with the main interface.
    func saveQuoteForWidget(_ quote: Quote) {
        let appGroupID = "group.com.wholeapp" // Ensure this matches your App Group ID
        if let userDefaults = UserDefaults(suiteName: appGroupID) {
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(quote) {
                userDefaults.set(data, forKey: "widgetDailyQuote")
            }
        }
    }

    // MARK: - UI Presentation Methods
    /// Presents the theme switcher UI by posting a notification.
    func showThemeSwitcher() {
        // Post a notification that can be observed by the main view to present the theme switcher.
        NotificationCenter.default.post(name: .showThemeSwitcher, object: nil)
    }

    /// Presents the settings UI by posting a notification.
    func showSettings() {
        // Post a notification that can be observed by the main view to present the settings screen.
        NotificationCenter.default.post(name: .showSettings, object: nil)
    }

    /// Presents the paywall UI by posting a notification.
    func showPaywall() {
        // Post a notification that can be observed by the main view to present the paywall modal.
        NotificationCenter.default.post(name: .showPaywall, object: nil)
    }

    // MARK: - Preview Support
    #if DEBUG
    /// Preview instance for SwiftUI previews.
    static var preview: QuoteViewModel {
        let vm = QuoteViewModel()
        vm.quotes = Quote.mockQuotes(limit: 5)
        return vm
    }
    #endif
}

// MARK: - Notification Names
// These notifications can be observed in the main view to trigger modals or navigation.
extension Notification.Name {
    static let showThemeSwitcher = Notification.Name("showThemeSwitcher")
    static let showSettings = Notification.Name("showSettings")
    static let showPaywall = Notification.Name("showPaywall")
}

// MARK: - Mock Data Extension for Preview/Testing
extension Quote {
    /// Generates mock quotes for preview/testing.
    static func mockQuotes(limit: Int) -> [Quote] {
        (0..<limit).map { i in
            Quote(
                id: UUID(), // Use UUID for id to match model
                englishText: "Sample Quote \(i+1)",
                chineseText: "示例语录 \(i+1)",
                categories: [QuoteCategory.inspiration, QuoteCategory.life],
                createdAt: Date(),
                createdBy: nil
            )
        }
    }
}
