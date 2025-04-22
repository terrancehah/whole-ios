// UserModel.swift
// Defines the data structure for a user profile as stored in Supabase.

import Foundation

/// Represents a user profile, matching the Supabase 'users' table.
struct UserProfile: Codable, Identifiable {
    /// Unique identifier for the user (UUID, matches auth.uid and Supabase)
    let id: UUID
    /// User's email address.
    let email: String
    /// User's display name (optional).
    let name: String?
    /// User's gender (optional).
    let gender: String?
    /// User's personal goals (optional).
    let goals: [String]?
    /// Subscription status (free, trial, monthly, yearly).
    let subscriptionStatus: String
    /// End date of free trial (optional).
    let trialEndDate: Date?
    /// Start date of paid subscription (optional).
    let subscriptionStartDate: Date?
    /// End date of paid subscription (optional).
    let subscriptionEndDate: Date?
    /// Timestamp for creation.
    let createdAt: Date?
    /// Timestamp for last update.
    let updatedAt: Date?

    // Coding keys to map Swift property names to Supabase/JSON keys.
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case gender
        case goals
        case subscriptionStatus = "subscription_status"
        case trialEndDate = "trial_end_date"
        case subscriptionStartDate = "subscription_start_date"
        case subscriptionEndDate = "subscription_end_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Sample UserProfile for Previews & Testing
extension UserProfile {
    /// Provides a sample user profile matching the schema, useful for SwiftUI previews and tests.
    static var sample: UserProfile {
        UserProfile(
            id: UUID(),
            email: "sample@wholeapp.com",
            name: "Sample User",
            gender: "Other",
            goals: ["Personal Growth", "Inner Peace"],
            subscriptionStatus: "free",
            trialEndDate: nil,
            subscriptionStartDate: nil,
            subscriptionEndDate: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
