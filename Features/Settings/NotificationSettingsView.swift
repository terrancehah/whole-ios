import SwiftUI

// NotificationSettingsView.swift
// Manage notification preferences.

struct NotificationSettingsView: View {
    @ObservedObject var userProfile: UserProfileViewModel
    var body: some View {
        Form {
            Section(header: Text("Notifications")) {
                // Toggle to enable/disable daily quote notifications, bound to userPreferences
                Toggle("Daily Quote Reminder", isOn: $userProfile.userPreferences.notificationsEnabled)
                    .onChange(of: userProfile.userPreferences.notificationsEnabled) { enabled in
                        userProfile.updateNotificationsEnabled(enabled)
                    }
                if userProfile.userPreferences.notificationsEnabled {
                    // Show time picker only if notifications are enabled
                    DatePicker("Notification Time", selection: Binding(
                        get: { userProfile.notificationTimeDate },
                        set: { userProfile.updateNotificationTime($0) }
                    ), displayedComponents: .hourAndMinute)
                }
                Button("Allow Notifications") {
                    userProfile.requestNotificationPermission()
                }.disabled(!userProfile.userPreferences.notificationsEnabled)
            }
        }
        .navigationTitle("Notifications")
    }
}

#if DEBUG
struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView(userProfile: UserProfileViewModel.mock)
    }
}
#endif
