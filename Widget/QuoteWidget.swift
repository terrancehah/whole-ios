// QuoteWidget.swift
// Main WidgetKit entry point for displaying daily quotes on lock screen/standby.

import WidgetKit
import SwiftUI

/// Main widget view displaying a bilingual quote in minimal style, themed to match the app.
struct QuoteWidgetView: View {
    let entry: QuoteWidgetEntry

    var body: some View {
        let theme = entry.theme.theme // Get Theme struct from AppTheme
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.quote.englishText)
                .font(theme.englishFont)
                .foregroundColor(theme.englishColor)
                .minimumScaleFactor(0.7)
                .lineLimit(2)
            Text(entry.quote.chineseText)
                .font(theme.chineseFont)
                .foregroundColor(theme.chineseColor)
                .minimumScaleFactor(0.7)
                .lineLimit(2)
            // Category chips (show on medium/large widgets)
            if !entry.quote.categories.isEmpty {
                HStack(spacing: 8) {
                    ForEach(entry.quote.categories, id: \ .self) { category in
                        Text(category.displayName)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(theme.cardBackground.opacity(0.15))
                            .foregroundColor(.accentColor)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(theme.cardBackground)
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
// QuoteWidget now applies app theme and category chips. It uses QuoteWidgetProvider for timeline and QuoteWidgetView for UI. MVP shows a random quote daily, no configuration.
