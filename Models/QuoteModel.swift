// QuoteModel.swift
// Defines the data structure for a quote as stored in Supabase.

import Foundation

/// Enum representing allowed quote categories.
enum QuoteCategory: String, CaseIterable, Codable, Identifiable {
    case inspiration = "Inspiration"
    case motivation = "Motivation"
    case love = "Love"
    case wisdom = "Wisdom"
    case life = "Life"
    case happiness = "Happiness"
    case compassion = "Compassion"
    case friendsAndFamily = "Friends & Family"
    case optimism = "Optimism"
    case unknown = "Unknown"

    /// For SwiftUI and UI display
    var id: String { rawValue }

    /// User-friendly display name
    var displayName: String {
        switch self {
        case .inspiration: return "Inspiration"
        case .motivation: return "Motivation"
        case .love: return "Love"
        case .wisdom: return "Wisdom"
        case .life: return "Life"
        case .happiness: return "Happiness"
        case .compassion: return "Compassion"
        case .friendsAndFamily: return "Friends & Family"
        case .optimism: return "Optimism"
        case .unknown: return "Unknown"
        }
    }

    /// Initialize from a string, defaulting to .unknown for unknown values
    init(fromRaw raw: String) {
        self = QuoteCategory.allCases.first(where: { $0.rawValue.caseInsensitiveCompare(raw) == .orderedSame }) ?? .unknown
    }
}

/// Represents a bilingual quote with metadata, matching the Supabase 'quotes' table.
struct Quote: Codable, Identifiable {
    /// Unique identifier for the quote (UUID string).
    let id: String
    /// The English text of the quote.
    let englishText: String
    /// The Chinese translation of the quote.
    let chineseText: String
    /// Categories/tags associated with the quote.
    let categories: [QuoteCategory]
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

    /// Custom decoding to support [String] -> [QuoteCategory]
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        englishText = try container.decode(String.self, forKey: .englishText)
        chineseText = try container.decode(String.self, forKey: .chineseText)
        let categoryStrings = try container.decode([String].self, forKey: .categories)
        categories = categoryStrings.map { QuoteCategory(fromRaw: $0) }
        createdAt = try? container.decodeIfPresent(Date.self, forKey: .createdAt)
        createdBy = try? container.decodeIfPresent(String.self, forKey: .createdBy)
    }

    /// Custom encoding to support [QuoteCategory] -> [String]
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(englishText, forKey: .englishText)
        try container.encode(chineseText, forKey: .chineseText)
        try container.encode(categories.map { $0.rawValue }, forKey: .categories)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(createdBy, forKey: .createdBy)
    }
}

// MARK: - Memberwise Initializer for Previews & Testing
extension Quote {
    /// Memberwise initializer for Quote, useful for previews and test data.
    init(
        id: String,
        englishText: String,
        chineseText: String,
        categories: [QuoteCategory],
        createdAt: Date? = nil,
        createdBy: String? = nil
    ) {
        self.id = id
        self.englishText = englishText
        self.chineseText = chineseText
        self.categories = categories
        self.createdAt = createdAt
        self.createdBy = createdBy
    }
}