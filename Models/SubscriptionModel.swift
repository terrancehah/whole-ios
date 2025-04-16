// SubscriptionModel.swift
// Defines the data structure for a user's subscription as stored in Supabase.

import Foundation

/// Represents a user's subscription status and related dates.
struct Subscription: Codable {
    /// Subscription status (free, trial, monthly, yearly).
    let status: String
    /// End date of free trial (optional).
    let trialEndDate: Date?
    /// Start date of paid subscription (optional).
    let startDate: Date?
    /// End date of paid subscription (optional).
    let endDate: Date?

    // Coding keys for mapping to Supabase/JSON fields.
    enum CodingKeys: String, CodingKey {
        case status = "subscription_status"
        case trialEndDate = "trial_end_date"
        case startDate = "subscription_start_date"
        case endDate = "subscription_end_date"
    }
}
