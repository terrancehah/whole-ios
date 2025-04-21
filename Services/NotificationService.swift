// NotificationService.swift
// Schedules and manages daily quote notifications and trial-end reminders.

import Foundation
import UserNotifications

/// NotificationService is responsible for requesting permissions, scheduling, and managing all local notifications in the app.
/// Supports both daily quote notifications (at user-selected time) and trial-end reminders (24h before trial ends).
final class NotificationService {
    // Singleton instance for global access
    static let shared = NotificationService()
    private let notificationCenter = UNUserNotificationCenter.current()
    private init() {}

    // MARK: - Authorization
    /// Requests notification authorization from the user.
    /// - Parameter completion: Called with true if granted, false otherwise.
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            completion(granted)
        }
    }

    // MARK: - Daily Quote Notification
    /// Schedules a daily notification at the specified time with the latest quote.
    /// - Parameters:
    ///   - time: The time to fire the notification (hour and minute).
    ///   - quote: The quote to display in the notification.
    func scheduleDailyQuoteNotification(at time: DateComponents, quote: Quote) {
        cancelDailyQuoteNotification() // Ensure only one scheduled
        let content = UNMutableNotificationContent()
        content.title = "Daily Inspiration"
        content.body = "\(quote.englishText)\n\(quote.chineseText)"
        content.sound = .default
        content.userInfo = ["quoteId": quote.id]
        let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyQuoteNotification", content: content, trigger: trigger)
        notificationCenter.add(request)
    }

    /// Cancels the scheduled daily quote notification.
    func cancelDailyQuoteNotification() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["dailyQuoteNotification"])
    }

    // MARK: - Trial-End Reminder
    /// Schedules a one-time notification 24 hours before the trial end date.
    /// - Parameter trialEndDate: The date when the user's trial ends.
    func scheduleTrialEndReminder(trialEndDate: Date) {
        cancelTrialEndReminder()
        guard let reminderDate = Calendar.current.date(byAdding: .hour, value: -24, to: trialEndDate) else { return }
        let content = UNMutableNotificationContent()
        content.title = "Trial Ending Soon"
        content.body = "Your Whole premium trial ends tomorrow! Unlock unlimited quotes and premium features."
        content.sound = .default
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: "trialEndReminder", content: content, trigger: trigger)
        notificationCenter.add(request)
    }

    /// Cancels the scheduled trial-end reminder notification.
    func cancelTrialEndReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["trialEndReminder"])
    }

    // MARK: - Utility
    /// Checks if notification permissions are granted.
    func checkAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            completion(settings.authorizationStatus == .authorized)
        }
    }
    /// Checks if the daily quote notification is scheduled.
    func isDailyQuoteNotificationScheduled(completion: @escaping (Bool) -> Void) {
        notificationCenter.getPendingNotificationRequests { requests in
            let exists = requests.contains { $0.identifier == "dailyQuoteNotification" }
            completion(exists)
        }
    }
    /// Checks if the trial-end reminder is scheduled.
    func isTrialEndReminderScheduled(completion: @escaping (Bool) -> Void) {
        notificationCenter.getPendingNotificationRequests { requests in
            let exists = requests.contains { $0.identifier == "trialEndReminder" }
            completion(exists)
        }
    }
}

// MARK: - Usage Example
// To schedule a daily quote notification:
// NotificationService.shared.scheduleDailyQuoteNotification(at: timeComponents, quote: latestQuote)
// To schedule a trial-end reminder:
// NotificationService.shared.scheduleTrialEndReminder(trialEndDate: userTrialEndDate)
// All methods are robust, commented, and ready for integration with SettingsViewModel, PaywallViewModel, etc.
