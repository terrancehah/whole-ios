// UserProfileViewModel.swift
// ObservableObject for managing and syncing the current user's profile and subscription state.

import Foundation
import Combine

/// ViewModel to manage fetching and state of the current user's profile from Supabase.
final class UserProfileViewModel: ObservableObject {
    /// Published user profile for use in the UI.
    @Published var user: UserProfile
    /// Published user preferences for notification and category settings.
    @Published var userPreferences: UserPreferences = UserPreferences(userId: UUID(), selectedCategories: [], notificationTime: "08:00", notificationsEnabled: false)
    /// True if user preferences have been loaded from backend. Used to gate quote fetching in main interface.
    @Published var isPreferencesLoaded: Bool = false
    /// Published property to track loading state.
    @Published var isLoading: Bool = false
    /// Published property for error messages.
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    /// Initialize with a sample user profile.
    init(user: UserProfile = UserProfile.sample) {
        self.user = user
        // Initialize userPreferences based on the initial user's ID
        self.userPreferences = UserPreferences(userId: user.id, selectedCategories: [], notificationTime: "08:00", notificationsEnabled: false)
    }

    /// Synchronizes the ViewModel's user state with AuthService.shared.user.
    /// This should be called when the authentication state might have changed.
    @MainActor
    func syncWithAuthServiceUser() {
        if let authUser = AuthService.shared.user {
            // Check if the current ViewModel's user ID is different from the authenticated user's ID.
            // This indicates a change in user or an initial sync from a default state.
            if self.user.id != authUser.id {
                print("[DEBUG] UserProfileViewModel syncWithAuthServiceUser: Auth user ID \(authUser.id) differs from current VM user ID \(self.user.id). Updating VM user.")
                // Create a new UserProfile with core details from the authenticated user.
                // Other details (name, goals, subscription) will be populated by fetchUserProfile.
                self.user = UserProfile(
                    id: authUser.id,
                    email: authUser.email,
                    name: nil, // Will be fetched by fetchUserProfile
                    gender: nil, // Will be fetched
                    goals: nil, // Will be fetched
                    subscriptionStatus: "free", // Default, will be fetched
                    trialEndDate: nil, // Will be fetched
                    subscriptionStartDate: nil, // Will be fetched
                    subscriptionEndDate: nil, // Will be fetched
                    createdAt: nil, // Will be fetched
                    updatedAt: nil // Will be fetched
                )
                // Reset preferences for the new user; these will also be fetched.
                self.userPreferences = UserPreferences(userId: authUser.id, selectedCategories: [], notificationTime: "08:00", notificationsEnabled: false)
                self.isPreferencesLoaded = false // Mark preferences as not loaded for the new user
            } else {
                print("[DEBUG] UserProfileViewModel syncWithAuthServiceUser: Auth user ID \(authUser.id) matches current VM user ID. No sync needed for basic user identity.")
            }
        } else {
            // No authenticated user in AuthService. Reset ViewModel to a default/sample state.
            print("[DEBUG] UserProfileViewModel syncWithAuthServiceUser: No authenticated user in AuthService. Resetting VM to sample profile.")
            let sampleUser = UserProfile.sample // Use a consistent sample user
            self.user = sampleUser
            self.userPreferences = UserPreferences(userId: sampleUser.id, selectedCategories: [], notificationTime: "08:00", notificationsEnabled: false)
            self.isPreferencesLoaded = false
        }
    }

    /// Fetch the current user's profile from Supabase using SupabaseService.
    func fetchUserProfile(userId: UUID) {
        isLoading = true
        errorMessage = nil
        SupabaseService.shared.fetchUserProfile(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let profile):
                    self?.user = profile
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    /// Refresh the user profile (call after purchase/restore or on app launch).
    func refresh(userId: UUID) {
        fetchUserProfile(userId: userId)
        fetchUserPreferences(userId: userId)
    }

    /// Fetch the user's preferences from Supabase and update the local model
    func fetchUserPreferences(userId: UUID) {
        SupabaseService.shared.fetchUserPreferences(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let preferences):
                    self?.userPreferences = preferences
                    self?.isPreferencesLoaded = true // Mark preferences as loaded
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.isPreferencesLoaded = true // Still mark as loaded to avoid indefinite loading
                }
            }
        }
    }

    // MARK: - Category Preferences
    /**
     Updates the user's selected categories both locally and on the backend (Supabase).
     - Parameters:
        - categories: The new set of selected categories.
        - completion: Completion handler with a Result indicating success or failure.
     */
    func updateSelectedCategories(_ categories: Set<QuoteCategory>, completion: @escaping (Result<Void, Error>) -> Void) {
        // Convert Set to Array for storage
        let updatedCategories = Array(categories)
        // Update the local userPreferences model
        self.userPreferences = UserPreferences(
            userId: userPreferences.userId,
            selectedCategories: updatedCategories,
            notificationTime: userPreferences.notificationTime,
            notificationsEnabled: userPreferences.notificationsEnabled
        )
        // Sync the updated preferences to Supabase
        // Call the new SupabaseService method that updates selected_categories
        SupabaseService.shared.updateUserPreferences(
            userId: userPreferences.userId,
            selectedCategories: updatedCategories
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: - Notification Preferences
    /// Bindable date for the notification time picker
    var notificationTimeDate: Date {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.date(from: userPreferences.notificationTime) ?? Date()
        }
        set {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            self.userPreferences = UserPreferences(userId: userPreferences.userId, selectedCategories: userPreferences.selectedCategories, notificationTime: formatter.string(from: newValue), notificationsEnabled: userPreferences.notificationsEnabled)
        }
    }

    /// Loads the latest shown quote from App Group UserDefaults (used for widget and notifications)
    private func loadLatestQuoteFromUserDefaults() -> Quote? {
        let appGroupID = "group.com.wholeapp" // Update to your actual App Group ID
        let userDefaults = UserDefaults(suiteName: appGroupID)
        guard let data = userDefaults?.data(forKey: "widgetDailyQuote") else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(Quote.self, from: data)
    }

    /// Schedules or cancels the daily quote notification based on user preferences.
    private func updateDailyQuoteNotification() {
        if userPreferences.notificationsEnabled {
            // Parse notification time (HH:mm) to DateComponents
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            guard let date = formatter.date(from: userPreferences.notificationTime) else { return }
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: date)
            // Load the latest shown quote
            if let quote = loadLatestQuoteFromUserDefaults() {
                NotificationService.shared.scheduleDailyQuoteNotification(at: components, quote: quote)
            }
        } else {
            NotificationService.shared.cancelDailyQuoteNotification()
        }
    }

    /// Update notificationsEnabled and sync to Supabase, also schedule/cancel notifications
    func updateNotificationsEnabled(_ enabled: Bool) {
        self.userPreferences = UserPreferences(userId: userPreferences.userId, selectedCategories: userPreferences.selectedCategories, notificationTime: userPreferences.notificationTime, notificationsEnabled: enabled)
        SupabaseService.shared.updateUserPreferences(userId: userPreferences.userId, notificationsEnabled: enabled) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if enabled {
                        // Request permission and schedule notification if not already scheduled
                        self?.requestNotificationPermission()
                        self?.updateDailyQuoteNotification() // Schedule notification
                    } else {
                        // Cancel any scheduled notifications
                        self?.updateDailyQuoteNotification() // Cancel notification
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    /// Update notification time and sync to Supabase, also reschedule notification
    func updateNotificationTime(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: date)
        self.userPreferences = UserPreferences(userId: userPreferences.userId, selectedCategories: userPreferences.selectedCategories, notificationTime: timeString, notificationsEnabled: userPreferences.notificationsEnabled)
        SupabaseService.shared.updateUserPreferences(userId: userPreferences.userId, notificationTime: timeString) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if self?.userPreferences.notificationsEnabled == true {
                        // Reschedule notification
                        self?.updateDailyQuoteNotification()
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    /// Request notification permission from settings
    func requestNotificationPermission() {
        NotificationService.shared.requestAuthorization { granted in
            DispatchQueue.main.async {
                if !granted {
                    self.userPreferences = UserPreferences(userId: self.userPreferences.userId, selectedCategories: self.userPreferences.selectedCategories, notificationTime: self.userPreferences.notificationTime, notificationsEnabled: false)
                }
            }
        }
    }

    // MARK: - Preview
    #if DEBUG
    static var preview: UserProfileViewModel {
        UserProfileViewModel(user: UserProfile.sample)
    }
    #endif
}

// MARK: - Mock for Previews & Testing
#if DEBUG
extension UserProfileViewModel {
    /// Provides a mock instance of UserProfileViewModel for SwiftUI previews and testing.
    static var mock: UserProfileViewModel {
        // Create a mock user profile using the sample extension
        let mockProfile = UserProfile.sample
        // Create mock user preferences (update selectedCategories as needed)
        let mockPreferences = UserPreferences(
            userId: UUID(),
            selectedCategories: [], // Add mock categories if desired
            notificationTime: "08:00",
            notificationsEnabled: true
        )
        // Initialize the view model and assign mock preferences
        let viewModel = UserProfileViewModel(user: mockProfile)
        viewModel.userPreferences = mockPreferences
        return viewModel
    }
}
#endif

// When updating userPreferences, always assign a new value:
// Example:
// self.userPreferences = UserPreferences(userId: ..., selectedCategories: ..., notificationTime: ..., notificationsEnabled: ...)
