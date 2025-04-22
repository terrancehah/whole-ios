// UserQuoteModel.swift
// Defines the data structure for user-generated quotes as stored in Supabase.

import Foundation

/// Represents a quote created by a user (premium feature), matching the Supabase 'userquotes' table.
struct UserQuote: Codable, Identifiable {
    /// Unique identifier for the user quote (UUID, matches Supabase)
    let id: UUID
    /// UUID of the user who created the quote.
    let userId: UUID
    /// English text of the quote.
    let englishText: String
    /// Chinese translation of the quote.
    let chineseText: String
    /// Timestamp for when the quote was created.
    let createdAt: Date?

    // Coding keys for mapping Swift property names to Supabase/JSON fields.
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case englishText = "english_text"
        case chineseText = "chinese_text"
        case createdAt = "created_at"
    }
}
