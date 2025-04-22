// UserPreferencesModel.swift
// Defines the data structure for user preferences as stored in Supabase.

import Foundation

/// Represents user preferences for categories and notifications, matching the Supabase 'userpreferences' table.
struct UserPreferences: Codable {
    let userId: UUID
    var selectedCategories: [QuoteCategory] // Mutable for category changes
    var notificationTime: String // Mutable for time changes
    var notificationsEnabled: Bool // Mutable for toggling notifications

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case selectedCategories = "selected_categories"
        case notificationTime = "notification_time"
        case notificationsEnabled = "notifications_enabled"
    }
}
