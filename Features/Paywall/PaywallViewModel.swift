// PaywallViewModel.swift
// Handles paywall logic, subscription state, and trial reminders.

import SwiftUI
import Combine
import StoreKit

/// ViewModel for handling paywall logic, subscription state, and trial reminders.
class PaywallViewModel: ObservableObject {
    // Published properties for UI state
    @Published var isTrialActive: Bool = true
    @Published var trialDay: Int = 1
    @Published var showReminderToggle: Bool = false
    @Published var reminderEnabled: Bool = false
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String? = nil
    @Published var subscriptionStatus: String = "free" // free, trial, monthly, yearly
    @Published var trialEndDate:procee Date? = nil
    @Published var subscriptionStartDate: Date? = nil
    @Published var subscriptionEndDate: Date? = nil
    @Published var purchaseSuccess: Bool = false

    // Subscription info (updated for 7-day trial)
    let trialLengthDays: Int = 7 // 7-day trial period
    let yearlyPrice: Double = 79.90
    let yearlyPriceString: String = "RM79.90 per year (RM 6.65/month)"
    let productID: String = "com.wholeapp.yearly"

    private var cancellables = Set<AnyCancellable>()

    // MARK: - StoreKit Integration (Stubbed for now)
    /// Start the 7-day free trial and initiate purchase flow.
    func startTrial() {
        isProcessing = true
        errorMessage = nil
        // TODO: Integrate with StoreKit 2 purchase API
        // Simulate success for now
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.isTrialActive = true
            self.trialDay = 1
            self.trialEndDate = Calendar.current.date(byAdding: .day, value: self.trialLengthDays, to: Date())
            self.subscriptionStatus = "trial"
            self.isProcessing = false
            self.purchaseSuccess = true
            // TODO: Save to backend (Supabase) and update user profile
        }
    }

    /// Restore previous purchases using StoreKit
    func restorePurchase() {
        isProcessing = true
        errorMessage = nil
        // TODO: Integrate with StoreKit restore API
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Simulate restore
            self.subscriptionStatus = "yearly"
            self.subscriptionStartDate = Date()
            self.subscriptionEndDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
            self.isProcessing = false
            self.purchaseSuccess = true
            // TODO: Save to backend (Supabase) and update user profile
        }
    }

    /// Toggle reminder for trial end (schedules/cancels notification)
    func toggleReminder() {
        reminderEnabled.toggle()
        // TODO: Implement notification scheduling/cancellation
        // Reminder is set to trigger 24 hours before trial ends
    }

    /// Check if user is premium (trial or paid)
    var isPremium: Bool {
        subscriptionStatus == "trial" || subscriptionStatus == "monthly" || subscriptionStatus == "yearly"
    }
}
