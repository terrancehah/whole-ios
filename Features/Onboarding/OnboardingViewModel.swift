// OnboardingViewModel.swift
// Handles onboarding state, user input, and onboarding logic.

import Foundation
import Combine
import UIKit

///ViewModel to manage onboarding flow, user input, and backend integration.
final class OnboardingViewModel: ObservableObject {
    // Published properties for each onboarding step
    @Published var currentStep: OnboardingStep = .welcome
    @Published var selectedCategories: Set<QuoteCategory> = []
    @Published var name: String = ""
    @Published var gender: String = ""
    @Published var goals: Set<String> = []
    @Published var additionalAnswers: [String: String] = [:]
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var onboardingCompleted: Bool = false
    @Published var notificationsEnabled: Bool = true // Default ON for onboarding UX
    @Published var notificationTime: String = "08:00" // Default time

    // Available options (could be fetched from backend in future)
    let allCategories = QuoteCategory.allCases.filter { $0 != .unknown }
    let allGenders = ["Male", "Female", "Other", "Prefer Not to Say"]
    let allGoals = ["Personal Growth", "Career Success", "Inner Peace"]

    // Combine cancellables
    private var cancellables = Set<AnyCancellable>()

    /// Enum representing each onboarding step
    enum OnboardingStep: Int, CaseIterable {
        case welcome
        case widgetIntro
        case preferences
        case notificationPreferences // NEW: Notification onboarding step
        case subscriptionIntro
        case completed
    }

    /// Proceed to the next step in onboarding
    func nextStep() {
        if let next = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            currentStep = next
        }
    }

    /// Go back to the previous step
    func previousStep() {
        if let prev = OnboardingStep(rawValue: currentStep.rawValue - 1) {
            currentStep = prev
        }
    }

    /// Save user preferences and profile to backend
    /// 
    /// This function now uses insertUserProfile and insertUserPreferences for new users,
    /// replacing any save/update calls. This is the recommended approach for new users.
    func savePreferencesAndProfile(userId: UUID, email: String) {
        isLoading = true
        errorMessage = nil

        // Construct user profile and preferences models
        let userProfile = UserProfile(
            id: userId,
            email: email,
            name: name.isEmpty ? nil : name,
            gender: gender.isEmpty ? nil : gender,
            goals: goals.isEmpty ? nil : Array(goals),
            subscriptionStatus: "free",
            trialEndDate: nil,
            subscriptionStartDate: nil,
            subscriptionEndDate: nil,
            createdAt: nil,
            updatedAt: nil
        )

        let userPreferences = UserPreferences(
            userId: userId,
            selectedCategories: Array(selectedCategories),
            notificationTime: notificationTime,
            notificationsEnabled: notificationsEnabled // Pass new field
        )

        // Insert user profile first, then preferences
        // This approach ensures data consistency and avoids potential update conflicts
        SupabaseService.shared.insertUserProfile(
            profile: userProfile
        ) { [weak self] profileResult in
            DispatchQueue.main.async {
                switch profileResult {
                case .success:
                    // If profile insert succeeds, insert preferences
                    SupabaseService.shared.insertUserPreferences(
                        preferences: userPreferences
                    ) { [weak self] prefResult in
                        DispatchQueue.main.async {
                            self?.isLoading = false
                            switch prefResult {
                            case .success:
                                self?.onboardingCompleted = true
                            case .failure(let error):
                                self?.errorMessage = error.localizedDescription
                            }
                        }
                    }
                case .failure(let error):
                    self?.isLoading = false
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    /// Skip optional fields (used for skip buttons)
    func skipName() { name = "" }
    func skipGender() { gender = "" }
    func skipGoals() { goals = [] }

    /// Requests notification permission if notifications are enabled.
    func requestNotificationPermission() {
        if notificationsEnabled {
            NotificationService.shared.requestAuthorization { granted in
                DispatchQueue.main.async {
                    if granted {
                        // Optionally, schedule notification here if needed
                    } else {
                        // Optionally, handle denied state (show alert, etc.)
                        self.notificationsEnabled = false
                    }
                }
            }
        }
    }
}
