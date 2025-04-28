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

    var body: some View {
        Group {
            if isAuthReady {
                if didCompleteOnboarding {
                    TabView {
                        // Quotes Tab (placeholder)
                        Text("Quotes")
                            .headingFont(size: 22) // Apply heading font to tab label
                            .tabItem {
                                Label("Quotes", systemImage: "quote.bubble")
                                    .bodyFont(size: 12) // Tab label font
                            }
                        // Favorites Tab
                        FavoritesView(viewModel: favoritesViewModel)
                            .tabItem {
                                Label("Favorites", systemImage: "heart.fill")
                                    .bodyFont(size: 12)
                            }
                    }
                    .onAppear {
                        // Set the userId and fetch favorites after login
                        let userId = userProfileViewModel.user.id
                        favoritesViewModel.userId = userId
                        favoritesViewModel.fetchLikedQuotes()
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
            // Anonymous sign-in is now handled during onboarding, not at launch
            if AuthService.shared.session != nil || AuthService.shared.user != nil {
                // User is already authenticated (either from restored session or previous login)
                isAuthReady = true
            } else {
                // No session yet: UI will handle onboarding and anonymous account creation when needed
                isAuthReady = true
            }
        }
    }
}
