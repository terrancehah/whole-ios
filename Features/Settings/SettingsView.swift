// SettingsView.swift
// Main settings screen: categories, customization, subscription, widget, notifications.

import SwiftUI

/// Main Settings view that owns the user profile view model and passes it to child settings screens.
struct SettingsView: View {
    // Own the user profile view model for all settings-related screens
    @StateObject private var userProfileViewModel = UserProfileViewModel()
    // Example: Assume you have a way to get the current user id (e.g. from auth)
    let userId: String

    var body: some View {
        NavigationView {
            List {
                // Customization section
                NavigationLink(destination: CustomizationView(userProfile: userProfileViewModel)) {
                    Label("Customization", systemImage: "paintbrush")
                }
                // Subscription section
                NavigationLink(destination: SubscriptionView(userProfile: userProfileViewModel)) {
                    Label("Subscription", systemImage: "star.fill")
                }
                // Profile section
                NavigationLink(destination: ProfileView(userProfile: userProfileViewModel)) {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                // Widget section
                NavigationLink(destination: WidgetSettingsView(userProfile: userProfileViewModel)) {
                    Label("Widget", systemImage: "rectangle.stack.fill")
                }
                // Notifications section
                NavigationLink(destination: NotificationSettingsView(userProfile: userProfileViewModel)) {
                    Label("Notifications", systemImage: "bell.fill")
                }
            }
            .navigationTitle("Settings")
            .background(ThemeManager.shared.selectedTheme.theme.background)
            .onAppear {
                // Sync the user profile on appear
                userProfileViewModel.refresh(userId: userId)
            }
        }
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(userId: "mock-user-id")
    }
}
#endif
