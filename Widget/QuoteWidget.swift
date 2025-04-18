// QuoteWidget.swift
// Main WidgetKit entry point for displaying daily quotes on lock screen/standby.

import WidgetKit
import SwiftUI

/// Main widget view displaying a bilingual quote in minimal style.
struct QuoteWidgetView: View {
    let entry: QuoteWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.quote.englishText)
                .font(.headline)
                .foregroundColor(.primary)
                .minimumScaleFactor(0.7)
                .lineLimit(2)
            Text(entry.quote.chineseText)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .minimumScaleFactor(0.7)
                .lineLimit(2)
        }
        .padding()
        .background(Color(.systemBackground))
        .widgetURL(URL(string: "whole://quote/\(entry.quote.id)")) // Deep link to quote in app
    }
}

@main
struct QuoteWidget: Widget {
    let kind: String = "QuoteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuoteWidgetProvider()) { entry in
            QuoteWidgetView(entry: entry)
        }
        .configurationDisplayName("Daily Quote")
        .description("Displays a daily bilingual quote on your lock screen or standby.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Comment
// QuoteWidget is the main entry for WidgetKit. It uses QuoteWidgetProvider for timeline and QuoteWidgetView for UI. MVP shows a random quote daily, no configuration.
