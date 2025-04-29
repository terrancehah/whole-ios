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
    @AppStorage("didCompleteOnboarding") private var didCompleteOnboarding: Bool = false
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    @StateObject private var userProfileViewModel = UserProfileViewModel()
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
                            viewModel: QuoteViewModel(user: userProfileViewModel.user),
                            userProfile: userProfileViewModel
                        )

                        // Overlay all four action buttons in corners
                        // Top right: Settings
                        VStack {
                            HStack {
                                Spacer()
                                // Add shadow to settings button for consistent design
                                CustomButton(
                                    label: "",
                                    systemImage: "gearshape",
                                    action: { showSettingsSheet = true },
                                    color: ThemeManager.shared.selectedTheme.theme.cardBackground
                                )
                                .frame(width: 48, height: 48)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
                                Spacer()
                            }
                            Spacer()
                        }
                        .padding(.top, 32)
                        .padding(.trailing, 22)
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
                                    // Add shadow to paywall button for consistent design
                                    CustomButton(
                                        label: "",
                                        systemImage: "star.fill",
                                        action: { showPaywallSheet = true },
                                        color: ThemeManager.shared.selectedTheme.theme.cardBackground
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
                        // Bottom right: Customization
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                // Add shadow to customization button for consistent design
                                CustomButton(
                                    label: "",
                                    systemImage: "paintbrush",
                                    action: { showCustomizationSheet = true },
                                    color: ThemeManager.shared.selectedTheme.theme.cardBackground
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
                                // Add shadow to favorites button for consistent design
                                CustomButton(
                                    label: "",
                                    systemImage: "heart.fill",
                                    action: {
                                        favoritesViewModel.userId = userProfileViewModel.user.id
                                        favoritesViewModel.fetchLikedQuotes()
                                        showFavoritesSheet = true
                                    },
                                    color: ThemeManager.shared.selectedTheme.theme.cardBackground
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
        .task {
            // Check if there is an existing authenticated session (anonymous or real)
            if AuthService.shared.session != nil || AuthService.shared.user != nil {
                isAuthReady = true
            } else {
                isAuthReady = true
            }
        }
    }
}
