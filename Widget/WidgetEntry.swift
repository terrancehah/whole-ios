// WidgetEntry.swift
// Provides timeline entries and configuration for the QuoteWidget.

import WidgetKit
import SwiftUI
import Foundation

/// Entry for the QuoteWidget, representing a single point in the timeline.
struct QuoteWidgetEntry: TimelineEntry {
    let date: Date
    let quote: Quote
}

/// Timeline provider for the QuoteWidget.
struct QuoteWidgetProvider: TimelineProvider {
    // Placeholder data for widget preview
    func placeholder(in context: Context) -> QuoteWidgetEntry {
        QuoteWidgetEntry(date: Date(), quote: Quote(id: "demo", englishText: "Stay hungry, stay foolish.", chineseText: "求知若饥，虚心若愚。", categories: ["Inspiration"], createdAt: nil, createdBy: nil))
    }

    // Snapshot for widget gallery
    func getSnapshot(in context: Context, completion: @escaping (QuoteWidgetEntry) -> ()) {
        let entry = QuoteWidgetEntry(date: Date(), quote: Quote(id: "demo", englishText: "Stay hungry, stay foolish.", chineseText: "求知若饥，虚心若愚。", categories: ["Inspiration"], createdAt: nil, createdBy: nil))
        completion(entry)
    }

    // Provide the timeline for the widget (one quote per day)
    func getTimeline(in context: Context, completion: @escaping (Timeline<QuoteWidgetEntry>) -> ()) {
        // For MVP, use a hardcoded or random quote. Replace with Supabase fetch in production.
        let entry = QuoteWidgetEntry(date: Date(), quote: Quote(id: "demo", englishText: "Stay hungry, stay foolish.", chineseText: "求知若饥，虚心若愚。", categories: ["Inspiration"], createdAt: nil, createdBy: nil))
        // Next update: next day at midnight
        let nextUpdate = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Comment
// QuoteWidgetEntry and QuoteWidgetProvider are the core data and timeline logic for the widget. For MVP, quotes are static or random. In production, replace with real data fetch from Supabase or shared cache.
