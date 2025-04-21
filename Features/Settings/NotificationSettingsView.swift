import SwiftUI

// NotificationSettingsView.swift
// Manage notification preferences.

struct NotificationSettingsView: View {
    @ObservedObject var userProfile: UserProfileViewModel
    var body: some View {
        Form {
            Section(header: Text("Notifications")) {
                Toggle("Daily Quote Reminder", isOn: $userProfile.user.notificationsEnabled)
                    .onChange(of: userProfile.user.notificationsEnabled) { enabled in
                        userProfile.updateNotificationsEnabled(enabled)
                    }
                if userProfile.user.notificationsEnabled {
                    DatePicker("Notification Time", selection: $userProfile.notificationTimeDate, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .onChange(of: userProfile.notificationTimeDate) { date in
                            userProfile.updateNotificationTime(date)
                        }
                }
                Button("Allow Notifications") {
                    userProfile.requestNotificationPermission()
                }.disabled(!userProfile.user.notificationsEnabled)
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
