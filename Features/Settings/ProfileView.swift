import SwiftUI

// ProfileView.swift
// Shows and allows editing of user profile info.

struct ProfileView: View {
    @ObservedObject var userProfile: UserProfileViewModel
    var body: some View {
        Form {
            Section(header: Text("Account Info")) {
                Text("Name: \(userProfile.user.name)")
                Text("Email: \(userProfile.user.email)")
            }
            Section {
                Button("Edit Profile") {
                    // TODO: Implement edit profile
                }
                Button("Logout") {
                    // TODO: Implement logout
                }
            }
        }
        .background(ThemeManager.shared.selectedTheme.theme.background)
        .navigationTitle("Profile")
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userProfile: UserProfileViewModel.mock)
    }
}
#endif
