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
        ensureAnonymousUser()
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
            print("[Onboarding] Advancing to step: \(next)") // Debug: step advancement
            currentStep = next
            if next == .completed {
                print("[Onboarding] Reached .completed. Triggering savePreferencesAndProfile()") // Debug: completed step
                // Call savePreferencesAndProfile when onboarding is done to ensure user is inserted into the users table
                savePreferencesAndProfile()
                // Call completion handler if needed
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

    /// Save user preferences and profile to backend, ensuring MainActor isolation
    func savePreferencesAndProfile() {
        print("[Onboarding] Entered savePreferencesAndProfile()") // Debug: function entry
        Task { @MainActor in
            // Ensure the user is authenticated before saving preferences/profile.
            if AuthService.shared.user == nil {
                do {
                    print("[Onboarding] No authenticated user. Attempting anonymous sign in...")
                    // Create an anonymous account using Supabase's built-in mechanism
                    let signedInUser = try await AuthService.shared.signInSupabaseAnonymous()
                    // Force update AuthService.user in case the SDK does not trigger the onAuthStateChange immediately
                    AuthService.shared.user = signedInUser
                    print("[Onboarding] Anonymous sign in successful. User: \(String(describing: signedInUser))")
                } catch {
                    self.errorMessage = "Failed to create anonymous account: \(error.localizedDescription)"
                    print("[Onboarding][ERROR] Anonymous sign in failed: \(error.localizedDescription)")
                    return
                }
            }
            // Now fetch the authenticated user
            guard let user = AuthService.shared.user else {
                self.errorMessage = "Unable to get authenticated user."
                print("[Onboarding][ERROR] Unable to get authenticated user after sign in.")
                return
            }
            let uuid = user.id // user.id is already a UUID, no conversion needed
            let userEmail = user.email // For anonymous users, this may be nil
            print("[Onboarding] Authenticated user: \(uuid), email: \(String(describing: userEmail))")
            print("[Onboarding] Preparing to save user profile and preferences...")
            print("[Onboarding] Selected categories: \(selectedCategories)")
            print("[Onboarding] Name: \(name), Gender: \(gender), Goals: \(goals)")
            self.isLoading = true
            self.errorMessage = nil
            // Construct user profile and preferences models
            let userProfile = UserProfile(
                id: uuid, // Using UUID for user ID
                email: userEmail, // May be nil for anonymous users
                name: self.name.isEmpty ? nil : self.name,
                gender: self.gender.isEmpty ? nil : self.gender,
                goals: self.goals.isEmpty ? nil : Array(self.goals),
                subscriptionStatus: "free",
                trialEndDate: nil,
                subscriptionStartDate: nil,
                subscriptionEndDate: nil,
                createdAt: nil,
                updatedAt: nil
            )
            let userPreferences = UserPreferences(
                userId: uuid, // Using UUID for user ID
                selectedCategories: Array(self.selectedCategories),
                notificationTime: self.notificationTime,
                notificationsEnabled: self.notificationsEnabled
            )
            // Debug prints to check types and values
            print("[Onboarding][DEBUG] user.id type: \(type(of: user.id)), value: \(user.id)")
            print("[Onboarding][DEBUG] userProfile.id type: \(type(of: userProfile.id)), value: \(userProfile.id)")
            print("[Onboarding] UserProfile: \(userProfile)")
            print("[Onboarding] UserPreferences: \(userPreferences)")
            // Insert user profile first, then preferences
            SupabaseService.shared.insertUserProfile(
                profile: userProfile
            ) { [weak self] profileResult in
                DispatchQueue.main.async {
                    switch profileResult {
                    case .success:
                        print("[Onboarding] User profile insert SUCCESS.")
                        // If profile insert succeeds, insert preferences
                        SupabaseService.shared.insertUserPreferences(
                            preferences: userPreferences
                        ) { [weak self] prefResult in
                            DispatchQueue.main.async {
                                self?.isLoading = false
                                switch prefResult {
                                case .success:
                                    print("[Onboarding] User preferences insert SUCCESS.")
                                    self?.onboardingCompleted = true
                                case .failure(let error):
                                    print("[Onboarding][ERROR] User preferences insert FAILED: \(error.localizedDescription)")
                                    self?.errorMessage = error.localizedDescription
                                }
                            }
                        }
                    case .failure(let error):
                        print("[Onboarding][ERROR] User profile insert FAILED: \(error.localizedDescription)")
                        self?.isLoading = false
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }

    /// Ensures an anonymous user is signed in at the start of onboarding.
    func ensureAnonymousUser() {
        Task { @MainActor in
            if AuthService.shared.user == nil {
                do {
                    let signedInUser = try await AuthService.shared.signInSupabaseAnonymous()
                    AuthService.shared.user = signedInUser
                } catch {
                    self.errorMessage = "Failed to create anonymous account: \(error.localizedDescription)"
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
