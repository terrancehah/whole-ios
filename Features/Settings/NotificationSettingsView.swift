import SwiftUI

// NotificationSettingsView.swift
// Manage notification preferences.

struct NotificationSettingsView: View {
    @ObservedObject var userProfile: UserProfileViewModel
    var body: some View {
        Form {
            Section(header: Text("Notifications")) {
                Toggle("Daily Quote Reminder", isOn: .constant(true)) // TODO: Bind to real state
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
