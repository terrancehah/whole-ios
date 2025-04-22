// WholeApp.swift
// Main SwiftUI entry point for the Whole application.

import SwiftUI

/// Main app struct with TabView navigation for Quotes and Favorites.
@main
struct WholeApp: App {
    // Persistent onboarding completion flag
    @AppStorage("didCompleteOnboarding") private var didCompleteOnboarding: Bool = false
    // User/session state would be managed here in a real app
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    @StateObject private var userProfileViewModel = UserProfileViewModel() // Assuming this exists for session

    // Track onboarding presentation
    @State private var showOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            if didCompleteOnboarding {
                TabView {
                    // Quotes Tab (placeholder)
                    Text("Quotes")
                        .tabItem {
                            Label("Quotes", systemImage: "quote.bubble")
                        }
                    // Favorites Tab
                    FavoritesView(viewModel: favoritesViewModel)
                        .tabItem {
                            Label("Favorites", systemImage: "heart.fill")
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
        }
    }
}
