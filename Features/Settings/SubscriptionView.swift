import SwiftUI

// SubscriptionView.swift
// Shows subscription status, plan, trial info, and manage/upgrade options.

struct SubscriptionView: View {
    @ObservedObject var userProfile: UserProfileViewModel
    var body: some View {
        Form {
            Section(header: Text("Subscription Status")) {
                Text("Plan: \(userProfile.user.subscriptionStatus.capitalized)")
                if let trialEnd = userProfile.user.trialEndDate {
                    Text("Trial ends: \(trialEnd, formatter: dateFormatter)")
                }
            }
            Section {
                Button("Manage Subscription") {
                    // TODO: Trigger paywall or subscription management
                }
            }
        }
        .navigationTitle("Subscription")
    }
}

private let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .medium
    df.timeStyle = .none
    return df
}()

#if DEBUG
struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView(userProfile: UserProfileViewModel.mock)
    }
}
#endif
