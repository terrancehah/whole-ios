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
    @Published var trialEndDate: Date? = nil
    @Published var subscriptionStartDate: Date? = nil
    @Published var subscriptionEndDate: Date? = nil
    
    @Published var purchaseSuccess: Bool = false

    // Subscription info (updated for 7-day trial)
    let trialLengthDays: Int = 7 // 7-day trial period
    let yearlyPrice: Double = 79.90
    let yearlyPriceString: String = "RM79.90 per year (RM 6.65/month)"
    let productID: String = "com.wholeapp.yearly"

    private var cancellables = Set<AnyCancellable>()

    // MARK: - StoreKit Integration (Production)
    /// Start the 7-day free trial and initiate purchase flow using StoreKit 2.
    func startTrial() {
        isProcessing = true
        errorMessage = nil
        // Integrate with StoreKit 2 purchase API for free trial
        Task {
            do {
                // Fetch the product for the yearly subscription
                guard let product = try await Product.products(for: [productID]).first else {
                    self.errorMessage = "Unable to load subscription product."
                    self.isProcessing = false
                    return
                }
                // Start the purchase flow
                let result = try await product.purchase()
                switch result {
                case .success(let verification):
                    switch verification {
                    case .verified(let transaction):
                        // Grant trial access, update backend and local state
                        await MainActor.run {
                            self.isTrialActive = true
                            self.trialDay = 1
                            self.trialEndDate = Calendar.current.date(byAdding: .day, value: self.trialLengthDays, to: Date())
                            self.subscriptionStatus = "trial"
                            self.isProcessing = false
                            self.purchaseSuccess = true
                            // TODO: Save to backend (Supabase) and update user profile
                        }
                        // Finish the transaction
                        await transaction.finish()
                    case .unverified(_, let error):
                        await MainActor.run {
                            self.errorMessage = "Purchase verification failed: \(error.localizedDescription)"
                            self.isProcessing = false
                        }
                    }
                case .userCancelled:
                    await MainActor.run {
                        self.errorMessage = "Purchase cancelled."
                        self.isProcessing = false
                    }
                case .pending:
                    await MainActor.run {
                        self.errorMessage = "Purchase is pending approval."
                        self.isProcessing = false
                    }
                @unknown default:
                    await MainActor.run {
                        self.errorMessage = "Unknown purchase result."
                        self.isProcessing = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isProcessing = false
                }
            }
        }
    }

    /// Restore previous purchases using StoreKit 2
    func restorePurchase() {
        isProcessing = true
        errorMessage = nil
        Task {
            do {
                // Sync StoreKit transactions
                try await AppStore.sync()
                // Check for active subscription
                let statuses = await Product.SubscriptionInfo.status(for: productID)
                if let status = statuses.first, status.state == .subscribed {
                    await MainActor.run {
                        self.subscriptionStatus = "yearly"
                        self.subscriptionStartDate = status.renewalInfo.originalPurchaseDate
                        self.subscriptionEndDate = status.renewalInfo.expirationDate
                        self.isProcessing = false
                        self.purchaseSuccess = true
                        // TODO: Save to backend (Supabase) and update user profile
                    }
                } else {
                    await MainActor.run {
                        self.errorMessage = "No active subscription found to restore."
                        self.isProcessing = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isProcessing = false
                }
            }
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
