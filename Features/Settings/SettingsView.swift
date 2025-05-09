// SettingsView.swift
// Main settings screen: categories, customization, subscription, widget, notifications.

import SwiftUI

/// Main Settings view that owns the user profile view model and passes it to child settings screens.
struct SettingsView: View {
    // Own the user profile view model for all settings-related screens
    @StateObject private var userProfileViewModel = UserProfileViewModel()
    // Example: Assume you have a way to get the current user id (e.g. from auth)
    let userId: UUID

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Appearance").font(.headline)) {
                    NavigationLink(destination: CustomizationView(userProfile: userProfileViewModel)) {
                        Label("Customization", systemImage: "paintbrush")
                    }
                    NavigationLink(destination: WidgetSettingsView(userProfile: userProfileViewModel)) {
                        Label("Widget", systemImage: "rectangle.stack.fill")
                    }
                }
                Section(header: Text("Account").font(.headline)) {
                    NavigationLink(destination: PreferencesSettingsView(userProfile: userProfileViewModel)) {
                        Label("Preferences", systemImage: "slider.horizontal.3")
                    }
                    NavigationLink(destination: ProfileView(userProfile: userProfileViewModel)) {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
                    NavigationLink(destination: SubscriptionView(userProfile: userProfileViewModel)) {
                        Label("Subscription", systemImage: "star.fill")
                    }
                }
                Section(header: Text("Notifications").font(.headline)) {
                    NavigationLink(destination: NotificationSettingsView(userProfile: userProfileViewModel)) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(Text("Settings").font(.largeTitle).bold())
            .background(ThemeManager.shared.selectedTheme.theme.background.ignoresSafeArea())
            .onAppear {
                // Sync the user profile on appear
                Task {
                    await userProfileViewModel.refresh(userId: userId)
                }
            }
        }
    }
}

// Preferences settings view for updating selected categories
struct PreferencesSettingsView: View {
    @ObservedObject var userProfile: UserProfileViewModel
    @State private var tempSelectedCategories: Set<QuoteCategory> = []
    @State private var isSaving = false
    @State private var saveError: String?

    var body: some View {
        VStack(spacing: 0) {
            CategorySelectionView(
                selectedCategories: $tempSelectedCategories,
                allCategories: QuoteCategory.allCases.filter { $0 != .unknown },
                onSave: savePreferences
            )
            if isSaving {
                ProgressView("Saving...")
                    .padding(.top)
            }
            if let saveError = saveError {
                Text(saveError)
                    .foregroundColor(.red)
                    .padding(.top)
            }
            Spacer()
        }
        .navigationTitle("Preferences")
        .background(ThemeManager.shared.selectedTheme.theme.background.ignoresSafeArea())
        .onAppear {
            // Convert array to set for local editing
                tempSelectedCategories = Set(userProfile.userPreferences.selectedCategories)
        }
    }

    /// Save the updated preferences to the backend and update the view model.
    private func savePreferences() {
        isSaving = true
        saveError = nil
        userProfile.updateSelectedCategories(tempSelectedCategories) { result in
            isSaving = false
            switch result {
            case .success:
                // Optionally show a success indicator
                break
            case .failure(let error):
                saveError = "Failed to save preferences: \(error.localizedDescription)"
            }
        }
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(userId: UUID())
    }
}
#endif
