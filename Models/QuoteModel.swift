// QuoteModel.swift
// Defines the data structure for a quote as stored in Supabase.

import Foundation

/// Represents a bilingual quote with metadata, matching the Supabase 'quotes' table.
struct Quote: Codable, Identifiable {
    /// Unique identifier for the quote (UUID string).
    let id: String
    /// The English text of the quote.
    let englishText: String
    /// The Chinese translation of the quote.
    let chineseText: String
    /// Categories/tags associated with the quote.
    let categories: [String]
    /// Timestamp when the quote was created.
    let createdAt: Date?
    /// The UUID of the user who created the quote (optional, for user-generated content).
    let createdBy: String?

    // Coding keys to map Swift property names to Supabase/JSON keys.
    enum CodingKeys: String, CodingKey {
        case id
        case englishText = "english_text"
        case chineseText = "chinese_text"
        case categories
        case createdAt = "created_at"
        case createdBy = "created_by"
    }
}