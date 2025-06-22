// PaywallView.swift
// UI for displaying subscription options, free trial, and purchase flow.
// Updated 2025-04-24: Fully implements StoreKit 2 trial, restore, and premium benefit display per app docs.

import SwiftUI

/// Main paywall interface presenting free trial, timeline, and upgrade actions.
struct PaywallView: View {
    @ObservedObject var viewModel: PaywallViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // System background for light/dark mode (Serene Minimalism theme)
            ThemeManager.shared.selectedTheme.theme.background
                .ignoresSafeArea()
            VStack(spacing: 24) { // Reduced spacing for a tighter layout
                // Close button
                HStack {
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .padding(8)
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal)
                
                // Title & subtitle
                VStack(spacing: 4) {
                    Text("Unlock Premium")
                        .font(.largeTitle).fontWeight(.bold) // Increased font size
                        .multilineTextAlignment(.center)
                    Text("Start your 7-day free trial. No charge today.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8) // Reduced top padding

                // Premium benefits list
                VStack(alignment: .leading, spacing: 16) {
                    BenefitRowView(iconName: "infinity", text: "Unlimited quotes, no daily limit")
                    BenefitRowView(iconName: "photo.on.rectangle.angled", text: "No watermark on shared images")
                    BenefitRowView(iconName: "paintpalette", text: "Premium themes & fonts")
                    BenefitRowView(iconName: "square.and.pencil", text: "Create and save your own quotes")
                }
                .padding(20)
                .background(Color.purple.opacity(0.08))
                .cornerRadius(16)
                .padding(.horizontal)

                // Trial timeline (7-day trial visual)
                VStack(alignment: .leading, spacing: 16) {
                    TimelineRowView(iconName: "lock.fill", title: "Today", subtitle: "Get full access and see your mindset start to change")
                    Divider()
                    TimelineRowView(iconName: "bell.fill", title: "Day 6", subtitle: "Get a reminder that your trial ends in 24 hours")
                    Divider()
                    TimelineRowView(iconName: "calendar", title: "After day 7", subtitle: "Your free trial ends and you'll be charged, cancel anytime")
                }
                .padding(20)
                .background(Color.purple.opacity(0.08))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)
                
                // Reminder toggle
                HStack {
                    Text("Reminder before trial ends")
                        .font(.subheadline)
                    Spacer()
                    Toggle("", isOn: $viewModel.reminderEnabled)
                        .labelsHidden()
                        .onChange(of: viewModel.reminderEnabled) { _ in
                            viewModel.toggleReminder()
                        }
                }
                .padding(.horizontal)
                
                // Call-to-action button
                Button(action: {
                    viewModel.startTrial()
                }) {
                    Text(viewModel.isProcessing ? "Starting..." : "Start 7-day free trial now")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.purple]), startPoint: .leading, endPoint: .trailing)) // Reversed gradient
                        .cornerRadius(16)
                        .shadow(color: Color.pink.opacity(0.2), radius: 8, x: 0, y: 4) // Adjusted shadow
                }
                .padding(.horizontal)
                .disabled(viewModel.isProcessing)
                
                // Pricing info
                Text("Unlimited free access for 7 days, then \(viewModel.yearlyPriceString)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Error/status feedback
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                if viewModel.purchaseSuccess {
                    Text("Subscription activated! Enjoy premium features.")
                        .font(.footnote)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Links
                HStack(spacing: 24) {
                    Button("Restore") { viewModel.restorePurchase() }
                        .font(.footnote)
                        .foregroundColor(.accentColor)
                    Button("Terms & Conditions") { viewModel.openTerms() }
                        .font(.footnote)
                        .foregroundColor(.accentColor)
                    Button("Privacy Policy") { viewModel.openPrivacy() }
                        .font(.footnote)
                        .foregroundColor(.accentColor)
                }
                .padding(.bottom, 16)
            }
            .padding(.vertical, 8)
        }
    }
}

#if DEBUG
/// A helper view to display a single premium benefit with an icon and text.
struct BenefitRowView: View {
    let iconName: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundColor(AppColors.primaryText)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
                .foregroundColor(AppColors.primaryText)
            
            Spacer()
        }
    }
}

/// A helper view to display a single timeline event with an icon, title, and subtitle.
struct TimelineRowView: View {
    let iconName: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundColor(.purple)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primaryText)

                Text(subtitle)
                    .font(.footnote)
                    .foregroundColor(AppColors.secondaryText)
            }
            Spacer()
        }
    }
}

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView(viewModel: PaywallViewModel())
            .preferredColorScheme(.dark)
        PaywallView(viewModel: PaywallViewModel())
            .preferredColorScheme(.light)
    }
}
#endif
