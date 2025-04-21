// PaywallView.swift
// UI for displaying subscription options, free trial, and purchase flow.

import SwiftUI

/// Main paywall interface presenting free trial, timeline, and upgrade actions.
struct PaywallView: View {
    @ObservedObject var viewModel: PaywallViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // System background for light/dark mode
            ThemeManager.shared.selectedTheme.theme.background
                .ignoresSafeArea()
            VStack(spacing: 32) {
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
                
                VStack(spacing: 8) {
                    Text("How your free trial works")
                        .font(.title2).fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    Text("You won't be charged anything today")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 16)
                
                // Trial timeline (updated for 7-day trial)
                VStack(alignment: .leading, spacing: 0) {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 1.5)
                        .background(Color.clear)
                        .overlay(
                            VStack(alignment: .leading, spacing: 20) {
                                HStack(alignment: .top) {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.purple)
                                    VStack(alignment: .leading) {
                                        Text("Today")
                                            .fontWeight(.semibold)
                                        Text("Get full access and see your mindset start to change")
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                HStack(alignment: .top) {
                                    Image(systemName: "bell")
                                        .foregroundColor(.purple)
                                    VStack(alignment: .leading) {
                                        Text("Day 6")
                                            .fontWeight(.semibold)
                                        Text("Get a reminder that your trial ends in 24 hours")
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                HStack(alignment: .top) {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.purple)
                                    VStack(alignment: .leading) {
                                        Text("After day 7")
                                            .fontWeight(.semibold)
                                        Text("Your free trial ends and you'll be charged, cancel anytime before")
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(20)
                        )
                        .frame(maxWidth: .infinity)
                }
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
                        .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.pink]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(16)
                        .shadow(color: Color.purple.opacity(0.18), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                .disabled(viewModel.isProcessing)
                
                // Pricing info
                Text("Unlimited free access for 7 days, then \(viewModel.yearlyPriceString)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Links
                HStack(spacing: 24) {
                    Button("Restore") { viewModel.restorePurchase() }
                        .font(.footnote)
                        .foregroundColor(.accentColor)
                    Button("Terms & Conditions") { /* Open terms URL */ }
                        .font(.footnote)
                        .foregroundColor(.accentColor)
                    Button("Privacy Policy") { /* Open privacy URL */ }
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
struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView(viewModel: PaywallViewModel())
            .preferredColorScheme(.dark)
        PaywallView(viewModel: PaywallViewModel())
            .preferredColorScheme(.light)
    }
}
#endif
