// CustomizationView.swift
// UI for changing app background, theme, and font (premium features).

/// Main customization view for theme and font selection.
struct CustomizationView: View {
    // Observe the global theme manager
    @ObservedObject var themeManager = ThemeManager.shared
    // Inject the current user profile for gating logic
    @ObservedObject var userProfile: UserProfileViewModel
    // Controls paywall modal presentation
    @State private var showPaywall: Bool = false
    
    var isPremiumUser: Bool {
        // User is premium if subscription is not free and trial is active
        let now = Date()
        if userProfile.user.subscriptionStatus == "free" {
            if let trialEnd = userProfile.user.trialEndDate {
                return trialEnd > now
            }
            return false
        }
        return true
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Theme")) {
                    // Theme selection list
                    ForEach(AppTheme.allCases) { theme in
                        HStack {
                            Text(theme.displayName)
                            Spacer()
                            if themeManager.selectedTheme == theme {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                            // Lock icon for non-premium users
                            if !isPremiumUser && theme != .sereneMinimalism {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if isPremiumUser || theme == .sereneMinimalism {
                                themeManager.selectedTheme = theme
                            } else {
                                // Block selection and show paywall
                                showPaywall = true
                            }
                        }
                    }
                }
                // Additional sections for background/font can be added here
            }
            .navigationTitle("Customize")
            .sheet(isPresented: $showPaywall) {
                PaywallView(viewModel: PaywallViewModel())
            }
        }
    }
}

#if DEBUG
struct CustomizationView_Previews: PreviewProvider {
    static var previews: some View {
        // Inject a mock user profile for preview
        CustomizationView(userProfile: UserProfileViewModel.mock)
    }
}
#endif
