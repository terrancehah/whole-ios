// LikedQuoteModel.swift
// Model representing a liked quote, mapping to the LikedQuotes table in Supabase.

import Foundation

/// Represents a user's liked quote (favorite) in the app.
struct LikedQuote: Identifiable, Codable, Equatable {
    let id: UUID
    let user_id: UUID
    let quote_id: UUID
    let created_at: Date

    // Coding keys now match the property names directly.
    enum CodingKeys: String, CodingKey {
        case id
        case user_id
        case quote_id
        case created_at
    }
}
