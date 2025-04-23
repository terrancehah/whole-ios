// OnboardingViewModel.swift
// Handles onboarding state, user input, and onboarding logic.

import Foundation
import Combine
import UIKit

///ViewModel to manage onboarding flow, user input, and backend integration.
final class OnboardingViewModel: ObservableObject {
    // Add completion handler for onboarding
    private var onCompletion: (() -> Void)?

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
    @Published var notificationsEnabled: Bool = false // Default OFF for onboarding
    @Published var notificationTime: String = "08:00" // Default time

    // Available options (could be fetched from backend in future)
    let allCategories = QuoteCategory.allCases.filter { $0 != .unknown }
    let allGenders = ["Male", "Female", "Other", "Prefer Not to Say"]
    // First-person, narrative goals for onboarding to foster user engagement and manifestation
    let allGoals = [
        "I am becoming more resilient in the face of challenges.",
        "I practice mindfulness and live in the present moment.",
        "I am improving my overall health and well-being.",
        "I am achieving greater financial stability.",
        "I stay curious and keep learning new things.",
        "I am succeeding and growing in my career.",
        "I find inner peace and balance in my life.",
        "I am building stronger, more meaningful relationships.",
        "I make personal growth a daily habit."
    ]

    // Combine cancellables
    private var cancellables = Set<AnyCancellable>()

    /// Add initializer with completion handler
    init(onCompletion: (() -> Void)? = nil) {
        self.onCompletion = onCompletion
    }

    /// Enum representing each onboarding step
    enum OnboardingStep: Int, CaseIterable {
        case welcome
        case categories
        case name
        case goals
        case notificationPreferences
        case widgetIntro
        case subscriptionIntro
        case completed
    }

    /// Proceed to the next step in onboarding
    func nextStep() {
        if let next = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            currentStep = next
            if next == .completed {
                // Call completion handler when onboarding is done
                onCompletion?()
            }
        }
    }

    /// Go back to the previous step
    func previousStep() {
        if let prev = OnboardingStep(rawValue: currentStep.rawValue - 1), prev != .welcome {
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
