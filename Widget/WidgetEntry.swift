// WidgetEntry.swift
// Provides timeline entries and configuration for the QuoteWidget.

import WidgetKit
import SwiftUI
import Foundation

/// Entry for the QuoteWidget, representing a single point in the timeline.
struct QuoteWidgetEntry: TimelineEntry {
    let date: Date
    let quote: Quote
    let theme: AppTheme
}

/// Timeline provider for the QuoteWidget.
struct QuoteWidgetProvider: TimelineProvider {
    // Helper: Load user's preferred categories from UserDefaults (App Group)
    private func loadPreferredCategories() -> [QuoteCategory] {
        let defaults = UserDefaults(suiteName: "group.com.wholeapp.shared")
        if let rawStrings = defaults?.stringArray(forKey: "preferredCategories") {
            return rawStrings.compactMap { QuoteCategory(rawValue: $0) }
        }
        return [.inspiration] // fallback
    }

    // Helper: Load selected theme from UserDefaults (App Group)
    private func loadSelectedTheme() -> AppTheme {
        let defaults = UserDefaults(suiteName: "group.com.wholeapp.shared")
        if let raw = defaults?.string(forKey: "selectedTheme"), let theme = AppTheme(rawValue: raw) {
            return theme
        }
        return .sereneMinimalism // fallback
    }

    // Helper: Load the daily quote for the widget from App Group UserDefaults
    private func loadWidgetDailyQuote() -> Quote? {
        let defaults = UserDefaults(suiteName: "group.com.wholeapp.shared")
        if let data = defaults?.data(forKey: "widgetDailyQuote") {
            return try? JSONDecoder().decode(Quote.self, from: data)
        }
        return nil
    }

    // Helper: Fetch quotes from Supabase synchronously for widget (blocking, fallback to static if needed)
    private func fetchQuoteSync(categories: [QuoteCategory]) -> Quote {
        // NOTE: WidgetKit does not support async fetches. For MVP, use static data or shared cache. In production, pre-cache quotes in app and read from shared storage.
        // Here, fallback to static demo quote.
        return Quote(id: UUID(), englishText: "Stay hungry, stay foolish.", chineseText: "求知若饥，虚心若愚。", categories: [.inspiration], createdAt: nil, createdBy: nil)
    }

    func placeholder(in context: Context) -> QuoteWidgetEntry {
        QuoteWidgetEntry(date: Date(), quote: Quote(id: UUID(), englishText: "Stay hungry, stay foolish.", chineseText: "求知若饥，虚心若愚。", categories: [.inspiration], createdAt: nil, createdBy: nil), theme: .sereneMinimalism)
    }

    func getSnapshot(in context: Context, completion: @escaping (QuoteWidgetEntry) -> ()) {
        let quote = loadWidgetDailyQuote() ?? Quote(id: UUID(), englishText: "Stay hungry, stay foolish.", chineseText: "求知若饥，虚心若愚。", categories: [.inspiration], createdAt: nil, createdBy: nil)
        let entry = QuoteWidgetEntry(date: Date(), quote: quote, theme: loadSelectedTheme())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuoteWidgetEntry>) -> ()) {
        let quote = loadWidgetDailyQuote() ?? Quote(id: UUID(), englishText: "Stay hungry, stay foolish.", chineseText: "求知若饥，虚心若愚。", categories: [.inspiration], createdAt: nil, createdBy: nil)
        let theme = loadSelectedTheme()
        let entry = QuoteWidgetEntry(date: Date(), quote: quote, theme: theme)
        let nextUpdate = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Comment
// QuoteWidgetEntry and QuoteWidgetProvider now load theme and categories from App Group UserDefaults. For MVP, quote fetch is static; production should pre-cache quotes for widget access.
// Widget provider now loads the daily quote from shared storage (App Group UserDefaults). If not available, falls back to demo data.
