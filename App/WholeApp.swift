// WholeApp.swift
// Main SwiftUI entry point for the Whole application.

import SwiftUI

/// Main app struct with TabView navigation for Quotes and Favorites.
@main
struct WholeApp: App {
    var body: some Scene {
        WindowGroup {
            RootAppView()
                .preferredColorScheme(.light)
        }
    }
}

/// RootAppView ensures an authenticated (anonymous or real) user exists before showing onboarding or main UI.
struct RootAppView: View {
    @AppStorage("didCompleteOnboarding") private var didCompleteOnboarding: Bool = false
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    @StateObject private var userProfileViewModel = UserProfileViewModel()
    @StateObject private var quoteViewModel = QuoteViewModel()
    @State private var isAuthReady: Bool = false
    @State private var showFavoritesSheet: Bool = false
    @State private var showSettingsSheet: Bool = false
    @State private var showCustomizationSheet: Bool = false
    @State private var showPaywallSheet: Bool = false

    var body: some View {
        Group {
            if isAuthReady {
                if didCompleteOnboarding {
                    ZStack {
                        // Set main background to #ffeedf as per frontend guidelines
                        Color(hex: "#ffeedf").ignoresSafeArea()

                        // Main quote carousel fills the space
                        QuoteListView(
                            viewModel: quoteViewModel,
                            userProfile: userProfileViewModel
                        )

                        // Overlay all four action buttons in corners
                        // Top left: Paywall/Subscription (if not premium)
                        VStack {
                            HStack {
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
                                if !isPremiumUser {
                                    CustomButton(
                                        label: "",
                                        systemImage: "star.fill",
                                        action: { showPaywallSheet = true },
                                        color: ThemeManager.shared.selectedTheme.theme.floatingButtonBackground,
                                        foregroundColor: ThemeManager.shared.selectedTheme.theme.accentColor
                                    )
                                    .frame(width: 48, height: 48)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                        .padding(.top, 32)
                        .padding(.leading, 22)

                        // Bottom right: Settings and Customization
                        VStack {
                            Spacer()
                            HStack(spacing: 16) {
                                Spacer()
                                // Settings Button (Inner)
                                CustomButton(
                                    label: "",
                                    systemImage: "gearshape",
                                    action: { showSettingsSheet = true },
                                    color: ThemeManager.shared.selectedTheme.theme.floatingButtonBackground,
                                    foregroundColor: ThemeManager.shared.selectedTheme.theme.accentColor
                                )
                                .frame(width: 48, height: 48)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)

                                // Customization Button (Outer)
                                CustomButton(
                                    label: "",
                                    systemImage: "paintbrush",
                                    action: { showCustomizationSheet = true },
                                    color: ThemeManager.shared.selectedTheme.theme.floatingButtonBackground,
                                    foregroundColor: ThemeManager.shared.selectedTheme.theme.accentColor
                                )
                                .frame(width: 48, height: 48)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
                            }
                        }
                        .padding(.bottom, 32)
                        .padding(.trailing, 22)

                        // Bottom left: Favorites
                        VStack {
                            Spacer()
                            HStack {
                                CustomButton(
                                    label: "",
                                    systemImage: "heart",
                                    action: { 
                                        favoritesViewModel.userId = userProfileViewModel.user.id
                                        favoritesViewModel.fetchLikedQuotes()
                                        showFavoritesSheet = true
                                    },
                                    color: ThemeManager.shared.selectedTheme.theme.floatingButtonBackground,
                                    foregroundColor: ThemeManager.shared.selectedTheme.theme.accentColor
                                )
                                .frame(width: 48, height: 48)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
                                Spacer()
                            }
                        }
                        .padding(.bottom, 32)
                        .padding(.leading, 22)
                    }
                    // All sheets for modal views
                    .sheet(isPresented: $showFavoritesSheet) {
                        FavoritesView(viewModel: favoritesViewModel)
                    }
                    .sheet(isPresented: $showSettingsSheet) {
                        SettingsView(userId: userProfileViewModel.user.id)
                    }
                    .sheet(isPresented: $showCustomizationSheet) {
                        CustomizationView(userProfile: userProfileViewModel)
                    }
                    .sheet(isPresented: $showPaywallSheet) {
                        PaywallView(viewModel: PaywallViewModel())
                    }
                } else {
                    // Show onboarding if not complete
                    OnboardingView(viewModel: OnboardingViewModel(onCompletion: {
                        didCompleteOnboarding = true
                    }))
                }
            } else {
                ProgressView("Preparing app...")
            }
        }
        .onChange(of: isAuthReady) { ready in
            if ready {
                print("[DEBUG] RootAppView: isAuthReady is true. Syncing UserProfileViewModel with AuthService.")
                userProfileViewModel.syncWithAuthServiceUser() // Sync first

                // After sync, UserProfileViewModel.user.id should reflect the authenticated user (if any)
                let currentUserId = userProfileViewModel.user.id

                if let authUser = AuthService.shared.user {
                    // Ensure the synced user ID matches the actual auth user ID before fetching.
                    // This handles the case where sync might reset to a sample user if authUser was nil.
                    if currentUserId == authUser.id {
                        print("[DEBUG] RootAppView: Fetching profile and preferences for synced user ID: \(authUser.id)")
                        userProfileViewModel.fetchUserProfile(userId: authUser.id)
                        userProfileViewModel.fetchUserPreferences(userId: authUser.id)
                    } else {
                        // This case implies syncWithAuthServiceUser reset to a sample user because authUser became nil
                        // between the .task block and this .onChange, or some other inconsistency.
                        print("[WARNING] RootAppView: Post-sync UserProfileViewModel ID \(currentUserId) does not match AuthService user ID \(authUser.id). This may occur if auth state changed rapidly. Not fetching.")
                    }
                    quoteViewModel.user = userProfileViewModel.user // Keep QuoteViewModel's user in sync
                } else if didCompleteOnboarding {
                    // This means isAuthReady is true, didCompleteOnboarding is true, but no AuthService.shared.user.
                    // This is an inconsistent state post-onboarding, as onboarding should ensure a user exists.
                    print("[ERROR] RootAppView: isAuthReady is true, didCompleteOnboarding is true, but no AuthService.shared.user found. This is an inconsistent state. Forcing re-onboarding.")
                    didCompleteOnboarding = false // Reset to force re-onboarding
                } else {
                    // isAuthReady is true, no auth user, and onboarding not yet completed.
                    // This is the expected state for a fresh app launch leading to onboarding.
                    // OnboardingView will handle user creation via OnboardingViewModel.
                    print("[DEBUG] RootAppView: isAuthReady is true, no auth user yet. Onboarding will proceed.")
                }
            } else {
                print("[DEBUG] RootAppView: isAuthReady is false. Resetting UserProfileViewModel and not fetching preferences.")
                userProfileViewModel.syncWithAuthServiceUser() // Ensure VM is reset if auth becomes not ready
            }
        }
        .onChange(of: didCompleteOnboarding) { completed in
            // This ensures that after onboarding, if auth is ready, we fetch the fresh user data.
            if completed && isAuthReady {
                print("[DEBUG] RootAppView: didCompleteOnboarding is true. Re-syncing UserProfileViewModel and fetching data.")
                // Essentially re-run the core logic from .onChange(of: isAuthReady)
                userProfileViewModel.syncWithAuthServiceUser()
                if let authUser = AuthService.shared.user {
                    if userProfileViewModel.user.id == authUser.id { // Check if sync was successful
                        print("[DEBUG] RootAppView (post-onboarding): Fetching profile and preferences for user ID: \(authUser.id)")
                        userProfileViewModel.fetchUserProfile(userId: authUser.id)
                        userProfileViewModel.fetchUserPreferences(userId: authUser.id)
                    } else {
                        print("[WARNING] RootAppView (post-onboarding): UserProfileViewModel ID \(userProfileViewModel.user.id) mismatch with AuthService ID \(authUser.id) after sync.")
                    }
                    quoteViewModel.user = userProfileViewModel.user
                } else {
                    // This should ideally not happen if onboarding just completed successfully, as it creates a user.
                    print("[ERROR] RootAppView (post-onboarding): didCompleteOnboarding is true, but no AuthService.shared.user found. This is highly inconsistent.")
                }
            }
        }
        .task {
            print("[DEBUG] RootAppView .task: Entered. Waiting for AuthService to initialize.")
            // Wait for AuthService to complete its initialization
            for await initialized in AuthService.shared.$isInitialized.values {
                if initialized {
                    print("[DEBUG] RootAppView .task: AuthService is initialized.")
                    // Now check the user state from AuthService
                    if AuthService.shared.user != nil {
                        print("[DEBUG] RootAppView .task: User session found in AuthService. User ID: \(AuthService.shared.user!.id.uuidString)")
                    } else {
                        print("[DEBUG] RootAppView .task: No user session found in AuthService after initialization.")
                        // If no user, onboarding will handle creation. No need to create one here.
                    }
                    isAuthReady = true // Signal that RootAppView can proceed to check didCompleteOnboarding
                    break // Exit the loop once isInitialized is true
                }
            }
        }
    }
}
