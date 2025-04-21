// UserProfileViewModel.swift
// ObservableObject for managing and syncing the current user's profile and subscription state.

import Foundation
import Combine

/// ViewModel to manage fetching and state of the current user's profile from Supabase.
final class UserProfileViewModel: ObservableObject {
    /// Published user profile for use in the UI.
    @Published var user: UserProfile
    /// Published property to track loading state.
    @Published var isLoading: Bool = false
    /// Published property for error messages.
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    /// Initialize with a sample user profile.
    init(user: UserProfile = UserProfile.sample) {
        self.user = user
    }

    /// Fetch the current user's profile from Supabase using SupabaseService.
    func fetchUserProfile(userId: String) {
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
    func refresh(userId: String) {
        fetchUserProfile(userId: userId)
    }

    // MARK: - Notification Preferences
    /// Bindable date for the notification time picker
    var notificationTimeDate: Date {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.date(from: user.notificationTime) ?? Date()
        }
        set {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            user.notificationTime = formatter.string(from: newValue)
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
        if user.notificationsEnabled {
            // Parse notification time (HH:mm) to DateComponents
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            guard let date = formatter.date(from: user.notificationTime) else { return }
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
        user.notificationsEnabled = enabled
        SupabaseService.shared.updateUserPreferences(userId: user.userId, notificationsEnabled: enabled) { [weak self] result in
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
        user.notificationTime = timeString
        SupabaseService.shared.updateUserPreferences(userId: user.userId, notificationTime: timeString) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if self?.user.notificationsEnabled == true {
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
                    self.user.notificationsEnabled = false
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
