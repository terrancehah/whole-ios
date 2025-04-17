// PaywallViewModel.swift
// Handles paywall logic, subscription state, and trial reminders.

import SwiftUI
import Combine

/// ViewModel for handling paywall logic, subscription state, and trial reminders.
class PaywallViewModel: ObservableObject {
    // Published properties for UI state
    @Published var isTrialActive: Bool = true
    @Published var trialDay: Int = 1
    @Published var showReminderToggle: Bool = false
    @Published var reminderEnabled: Bool = false
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String? = nil

    // Subscription info (updated for 7-day trial)
    let trialLengthDays: Int = 7 // 7-day trial period
    let yearlyPrice: Double = 79.90
    let yearlyPriceString: String = "RM79.90 per year (RM 6.65/month)"

    // Methods for handling actions
    func startTrial() {
        // Simulate starting the trial
        isProcessing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.isTrialActive = true
            self.trialDay = 1
            self.isProcessing = false
        }
    }

    func toggleReminder() {
        reminderEnabled.toggle()
        // Implement notification scheduling/cancellation as needed
        // Reminder is set to trigger 24 hours before trial ends
    }

    func restorePurchase() {
        // Implement restore logic
    }
}
