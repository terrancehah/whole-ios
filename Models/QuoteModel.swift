// QuoteModel.swift
// Defines the data structure for a quote as stored in Supabase.

import Foundation

/// Enum representing allowed quote categories.
enum QuoteCategory: String, CaseIterable, Codable, Identifiable, Equatable {
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

    // Explicit Equatable conformance
    static func == (lhs: QuoteCategory, rhs: QuoteCategory) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

/// Represents a bilingual quote with metadata, matching the Supabase 'quotes' table.
struct Quote: Codable, Identifiable, Equatable {
    /// Unique identifier for the quote (UUID, matches Supabase)
    let id: UUID
    /// The English text of the quote.
    let englishText: String
    /// The Chinese translation of the quote.
    let chineseText: String
    /// Category/tag associated with the quote (was array, now single value)
    let category: QuoteCategory
    /// Timestamp when the quote was created.
    let createdAt: Date?
    /// The UUID of the user who created the quote (optional, for user-generated content).
    let createdBy: UUID?

    // Coding keys to map Swift property names to Supabase/JSON keys.
    enum CodingKeys: String, CodingKey {
        case id
        case englishText = "english_text"
        case chineseText = "chinese_text"
        case category
        case createdAt = "created_at"
        case createdBy = "created_by"
    }

    // Update decoding/encoding to handle UUID and single category
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        englishText = try container.decode(String.self, forKey: .englishText)
        chineseText = try container.decode(String.self, forKey: .chineseText)
        let categoryString = try container.decode(String.self, forKey: .category)
        category = QuoteCategory(fromRaw: categoryString)
        createdAt = try? container.decodeIfPresent(Date.self, forKey: .createdAt)
        createdBy = try? container.decodeIfPresent(UUID.self, forKey: .createdBy)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(englishText, forKey: .englishText)
        try container.encode(chineseText, forKey: .chineseText)
        try container.encode(category.rawValue, forKey: .category)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(createdBy, forKey: .createdBy)
    }

    // Equatable conformance will be synthesized by the compiler as all members are Equatable.
}

// MARK: - Memberwise Initializer for Previews & Testing
extension Quote {
    /// Memberwise initializer for Quote, useful for previews and test data.
    init(
        id: UUID,
        englishText: String,
        chineseText: String,
        category: QuoteCategory,
        createdAt: Date? = nil,
        createdBy: UUID? = nil
    ) {
        self.id = id
        self.englishText = englishText
        self.chineseText = chineseText
        self.category = category
        self.createdAt = createdAt
        self.createdBy = createdBy
    }
}