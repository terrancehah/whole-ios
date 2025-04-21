// LikedQuoteModel.swift
// Model representing a liked quote, mapping to the LikedQuotes table in Supabase.

import Foundation

/// Represents a user's liked quote (favorite) in the app.
struct LikedQuote: Identifiable, Codable, Equatable {
    let id: UUID
    let userId: UUID
    let quoteId: UUID
    let createdAt: Date

    // Coding keys to match Supabase column names
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case quoteId = "quote_id"
        case createdAt = "created_at"
    }
}
