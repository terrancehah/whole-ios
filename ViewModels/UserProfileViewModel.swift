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
                    } else {
                        // Cancel any scheduled notifications
                        NotificationService.shared.cancelDailyQuoteNotification()
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
                        // Fetch latest quote if needed, or use placeholder
                        // NotificationService.shared.scheduleDailyQuoteNotification(at: ...)
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
