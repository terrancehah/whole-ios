// AnalyticsService.swift
// Placeholder for future analytics integration (Firebase, etc.)

import Foundation

/// AnalyticsService is a stub for MVP. Replace with real analytics logic when needed.
final class AnalyticsService {
    static let shared = AnalyticsService()
    private init() {}

    /// Logs a generic event (no-op for MVP).
    func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        // No-op for MVP
    }
}
