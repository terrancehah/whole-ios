// UserPreferencesModel.swift
// Defines the data structure for user preferences as stored in Supabase.

import Foundation

/// Represents user preferences for categories and notifications, matching the Supabase 'userpreferences' table.
struct UserPreferences: Codable {
    let userId: String
    var selectedCategories: [QuoteCategory] // Made mutable to allow category changes
    var notificationTime: String // Made mutable to allow time changes
    var notificationsEnabled: Bool // Made mutable to allow toggling notifications

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case selectedCategories = "selected_categories"
        case notificationTime = "notification_time"
        case notificationsEnabled = "notifications_enabled" // NEW: Backend column
    }
}
