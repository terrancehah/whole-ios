// WholeApp.swift
// Main SwiftUI entry point for the Whole application.

import SwiftUI

/// Main app struct with TabView navigation for Quotes and Favorites.
@main
struct WholeApp: App {
    var body: some Scene {
        WindowGroup {
            RootAppView()
        }
    }
}

/// RootAppView ensures an authenticated (anonymous or real) user exists before showing onboarding or main UI.
struct RootAppView: View {
    // Renamed to avoid confusion with previous logic during refactoring.
    @AppStorage("didCompleteOnboarding") private var didCompleteOnboardingLocal: Bool = false
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    @StateObject private var userProfileViewModel = UserProfileViewModel()
    @StateObject private var quoteViewModel = QuoteViewModel()

    // State variables for sheets in the main app view, remain unchanged.
    @State private var showFavoritesSheet: Bool = false
    @State private var showSettingsSheet: Bool = false
    @State private var showCustomizationSheet: Bool = false
    @State private var showPaywallSheet: Bool = false

    // New state enum for managing view presentation.
    enum ViewState {
        case loading // Initial state, waiting for auth and data.
        case showOnboarding // Show onboarding flow.
        case showApp // Show main application UI.
    }
    // Current view state, defaults to loading.
    @State private var currentViewState: ViewState = .loading

    var body: some View {
        // Switch based on the current view state.
        switch currentViewState {
        case .loading:
            // Show a progress view while loading initial data.
            SwiftUI.ProgressView("Preparing your experience...")
        case .showOnboarding:
            // Show the onboarding view.
            OnboardingView(viewModel: OnboardingViewModel(onCompletion: {
                // This closure is called when OnboardingViewModel signals completion.
                // A user should now exist (either new or logged in).
                Task {
                    print("[DEBUG] RootAppView: Onboarding completed via OnboardingViewModel. Re-evaluating view to show.")
                    // Set the local flag indicating onboarding was attempted/completed.
                    self.didCompleteOnboardingLocal = true 
                    // Re-run the determination logic to transition to the main app or handle errors.
                    await self.determineViewToShow()
                }
            }))
        case .showApp:
            // Main application UI, previously inside 'if didCompleteOnboarding' block.
            ZStack {
                Color(hex: "#ffeedf").ignoresSafeArea() // Main background color.

                QuoteListView(
                    viewModel: quoteViewModel,
                    userProfile: userProfileViewModel
                )

                let now = Date()
                let isPremiumUser: Bool = {
                    let status = userProfileViewModel.user.subscriptionStatus
                    if status == "free" {
                        if let trialEnd = userProfileViewModel.user.trialEndDate {
                            return trialEnd > now
                        }
                        return false
                    }
                    return true
                }()

                // Unified Bottom Bar - structure remains the same.
                HStack(alignment: .center, spacing: 0) {
                    if !isPremiumUser {
                        CustomButton(
                            label: "",
                            systemImage: "star.fill",
                            action: { showPaywallSheet = true },
                            color: ThemeManager.shared.selectedTheme.theme.cardBackground
                        )
                        .frame(width: 48, height: 48)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
                        .foregroundColor(.black)
                    } else {
                        Spacer().frame(width: 48)
                    }
                    Spacer()
                    CustomButton(
                        label: "",
                        systemImage: "gearshape",
                        action: { showSettingsSheet = true },
                        color: ThemeManager.shared.selectedTheme.theme.cardBackground
                    )
                    .frame(width: 48, height: 48)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
                    .foregroundColor(.black)
                    Spacer()
                    CustomButton(
                        label: "",
                        systemImage: "heart",
                        action: { showFavoritesSheet = true },
                        color: ThemeManager.shared.selectedTheme.theme.cardBackground
                    )
                    .frame(width: 48, height: 48)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
                    .foregroundColor(.black)
                    Spacer()
                    CustomButton(
                        label: "",
                        systemImage: "wand.and.stars",
                        action: { showCustomizationSheet = true },
                        color: ThemeManager.shared.selectedTheme.theme.cardBackground
                    )
                    .frame(width: 48, height: 48)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
                    .foregroundColor(.black)
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 12)
                .background(AppColors.background) // Use AppColors.background for tab consistency
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                .padding(.bottom, SafeAreaInsetsKey.defaultValue.bottom == 0 ? 12 : 0)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            // Sheet presentations remain the same.
            .sheet(isPresented: $showFavoritesSheet) {
                FavoritesView(viewModel: favoritesViewModel)
            }
            .sheet(isPresented: $showSettingsSheet) {
                SettingsView(userId: userProfileViewModel.user.id)
                    .environmentObject(userProfileViewModel)
            }
            .sheet(isPresented: $showCustomizationSheet) {
                CustomizationView(userProfile: userProfileViewModel)
            }
            .sheet(isPresented: $showPaywallSheet) {
                PaywallView(viewModel: PaywallViewModel())
            }
        }
        .task {
            await determineViewToShow()
        }
    }

    // This function orchestrates the decision of which view to show.
    @MainActor
    private func determineViewToShow() async {
        print("[DEBUG] RootAppView determineViewToShow: Starting decision process. Current state: \(currentViewState)")

        // Step 1: Wait for AuthService to initialize.
        // This loop ensures we don't proceed until AuthService has established an auth state.
        for await initialized in AuthService.shared.$isInitialized.values {
            if initialized {
                print("[DEBUG] RootAppView determineViewToShow: AuthService is initialized.")
                break // Exit the loop once AuthService is ready.
            }
        }

        // Step 2: Sync UserProfileViewModel with the current auth state from AuthService.
        // This ensures our local user profile view model accurately reflects the authenticated user (if any).
        userProfileViewModel.syncWithAuthServiceUser()
        print("[DEBUG] RootAppView determineViewToShow: UserProfileViewModel synced. VM User ID: \(userProfileViewModel.user.id), Auth User: \(AuthService.shared.user?.id.uuidString ?? "nil")).")

        // Step 3: Check if there's an authenticated user.
        if let authUser = AuthService.shared.user {
            print("[DEBUG] RootAppView determineViewToShow: Authenticated user found (ID: \(authUser.id)). Fetching profile and preferences.")
            // An authenticated user exists. This could be a returning user or one just created/logged in via onboarding.
            
            // Fetch the user's profile and preferences from the backend.
            // These calls are now asynchronous and awaitable.
            await userProfileViewModel.fetchUserProfile(userId: authUser.id)
            await userProfileViewModel.fetchUserPreferences(userId: authUser.id)

            // Step 4: Decide based on fetched preferences.
            // Check if preferences are loaded and if essential setup (like selecting categories) is done.
            if userProfileViewModel.isPreferencesLoaded && !userProfileViewModel.userPreferences.selectedCategories.isEmpty {
                print("[DEBUG] RootAppView determineViewToShow: User preferences loaded AND categories selected. Transitioning to .showApp.")
                // User has completed essential setup. Show the main application.
                self.quoteViewModel.user = self.userProfileViewModel.user // Ensure QuoteViewModel has the latest user data.
                self.currentViewState = .showApp
                self.didCompleteOnboardingLocal = true // Also update the local flag as a confirmation.
            } else {
                print("[DEBUG] RootAppView determineViewToShow: User preferences not fully loaded or categories not selected (isPreferencesLoaded: \(userProfileViewModel.isPreferencesLoaded), categoriesEmpty: \(userProfileViewModel.userPreferences.selectedCategories.isEmpty)). Transitioning to .showOnboarding.")
                // Preferences are not loaded, or essential setup (like category selection) is incomplete.
                // This user needs to go through onboarding (or a part of it) to complete setup.
                self.currentViewState = .showOnboarding
            }
        } else {
            // Step 5: No authenticated user.
            print("[DEBUG] RootAppView determineViewToShow: No authenticated user found. Transitioning to .showOnboarding.")
            // This typically occurs on a fresh app install before any sign-in or anonymous user creation.
            // Direct to onboarding to create/log in the user.
            self.currentViewState = .showOnboarding
        }
        print("[DEBUG] RootAppView determineViewToShow: Decision process complete. Final view state: \(currentViewState).")
    }
}

// Helper for SafeAreaInsets - structure remains the same.
struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        (UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero).insets
    }
}

extension UIEdgeInsets {
    var insets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}
