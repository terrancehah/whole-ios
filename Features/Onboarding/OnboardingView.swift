// OnboardingView.swift
// Displays the onboarding flow: welcome, widget intro, preferences, notification preferences, and subscription intro.

import SwiftUI
import Combine
import UIKit

/// Main onboarding view presenting a multi-step onboarding flow.
struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        ZStack {
            // Apply theme color to the entire screen
            ThemeManager.shared.selectedTheme.theme.background.ignoresSafeArea()
            VStack {
                // Top navigation: Back and Skip
                HStack {
                    // Show back button except on the first step
                    if viewModel.currentStep != .welcome {
                        Button(action: viewModel.previousStep) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(Color(hex: "#ff9f68")) // Accent color
                                .padding(.leading)
                        }
                    }
                    Spacer()
                    // Show skip button if applicable (including widget intro step)
                    if showSkip(for: viewModel.currentStep) {
                        Button(action: skipCurrentStep) {
                            Text("Skip")
                                .bodyFont()
                                .foregroundColor(Color(hex: "#ff9f68")) // Accent color
                        }
                        .padding(.trailing)
                    }
                }
                .padding(.top)

                Spacer(minLength: 16)

                // Main content for each onboarding step
                switch viewModel.currentStep {
                case .welcome:
                    WelcomeStepView(onContinue: viewModel.nextStep)
                case .categories:
                    CategoriesStepView(selectedCategories: $viewModel.selectedCategories, allCategories: QuoteCategory.allCases.filter { $0 != .unknown }, onContinue: viewModel.nextStep)
                case .name:
                    NameStepView(name: $viewModel.name, onContinue: viewModel.nextStep)
                case .goals:
                    GoalsStepView(selectedGoals: $viewModel.goals, allGoals: viewModel.allGoals, onContinue: viewModel.nextStep)
                case .notificationPreferences:
                    NotificationPreferencesStepView(notificationsEnabled: $viewModel.notificationsEnabled, notificationTime: $viewModel.notificationTime, onContinue: viewModel.nextStep)
                case .widgetIntro:
                    WidgetIntroStepView(onContinue: viewModel.nextStep)
                case .subscriptionIntro:
                    SubscriptionIntroStepView(onContinue: viewModel.nextStep)
                case .completed:
                    Text("Onboarding Complete!").font(.title).padding()
                }

                Spacer()

                // Loading and error states
                if viewModel.isLoading {
                    ProgressView("Saving...").padding()
                }
                if let error = viewModel.errorMessage {
                    Text(error).foregroundColor(.red).padding()
                }
            }
        }
        .animation(.easeInOut, value: viewModel.currentStep)
    }

    // Helper to determine if skip button should be shown
    private func showSkip(for step: OnboardingViewModel.OnboardingStep) -> Bool {
        switch step {
        case .categories, .name, .goals, .subscriptionIntro, .widgetIntro:
            return true
        default:
            return false
        }
    }

    // Helper to handle skip logic for each step
    private func skipCurrentStep() {
        switch viewModel.currentStep {
        case .categories:
            viewModel.selectedCategories.removeAll()
            viewModel.nextStep()
        case .name:
            viewModel.name = ""
            viewModel.nextStep()
        case .goals:
            viewModel.goals.removeAll()
            viewModel.nextStep()
        case .subscriptionIntro:
            viewModel.nextStep() // Skips trial
        case .widgetIntro:
            viewModel.nextStep()
        default:
            break
        }
    }
}

// MARK: - Individual Step Views

/// Welcome step: Introduces the app.
struct WelcomeStepView: View {
    let onContinue: () -> Void
    var body: some View {
        VStack(spacing: 24) {
            Text("Welcome to Whole")
                .headingFont()
            Text("Your daily dose of inspiration in English and Chinese.")
                .bodyFont()
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Continue", action: onContinue)
                .buttonStyle(WarmPrimaryButtonStyle())
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            // The above ensures the button matches the width and horizontal padding of other onboarding buttons
        }
    }
}

// MARK: - Categories Step (Grid Selection)
struct CategoriesStepView: View {
    @Binding var selectedCategories: Set<QuoteCategory>
    let allCategories: [QuoteCategory]
    let onContinue: () -> Void

    let columns = [GridItem(.adaptive(minimum: 120), spacing: 16)]

    var body: some View {
        VStack(spacing: 28) {
            Text("Choose Your Preferred Categories")
                .headingFont()
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(allCategories, id: \.self) { category in
                    CategoryGridItem(category: category, isSelected: selectedCategories.contains(category)) {
                        if selectedCategories.contains(category) {
                            selectedCategories.remove(category)
                        } else {
                            selectedCategories.insert(category)
                        }
                    }
                }
            }
            .padding(.vertical)
            Button("Continue", action: onContinue)
                .buttonStyle(WarmPrimaryButtonStyle())
                .disabled(selectedCategories.isEmpty)
        }
        .padding(.horizontal)
    }
}

struct CategoryGridItem: View {
    let category: QuoteCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(category.displayName)
                .bodyFont()
                .padding()
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color(hex: "#ff9f68") : Color.white)
                .cornerRadius(12)
                .foregroundColor(isSelected ? Color.white : Color.primary)
                // Use a darker warm color (#b65f3b) for selected state, white otherwise. Invert text color for contrast.
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color(hex: "#ff9f68") : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                )
        }
        .animation(.easeInOut, value: isSelected)
    }
}

// MARK: - Name Step
struct NameStepView: View {
    @Binding var name: String
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Text("What's your name?")
                .headingFont()
                .multilineTextAlignment(.center)
            TextField("Enter your name (optional)", text: $name)
                .bodyFont()
                .padding(.vertical, 18) // Add more vertical padding for comfort
                .padding(.horizontal, 14)
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .padding(.bottom, 8)
            Button("Continue", action: onContinue)
                .buttonStyle(WarmPrimaryButtonStyle())
        }
        .padding(.horizontal)
    }
}

// MARK: - Goals Step (Grid Selection)
struct GoalsStepView: View {
    @Binding var selectedGoals: Set<String>
    let allGoals: [String]
    let onContinue: () -> Void

    let columns = [GridItem(.adaptive(minimum: 120), spacing: 16)]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 28) {
                    Text("Select Your Goals")
                        .headingFont()
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(allGoals, id: \.self) { goal in
                            GoalGridItem(goal: goal, isSelected: selectedGoals.contains(goal)) {
                                if selectedGoals.contains(goal) {
                                    selectedGoals.remove(goal)
                                } else {
                                    selectedGoals.insert(goal)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .padding(.horizontal)
                .padding(.top, 28)
            }
            Button("Continue", action: onContinue)
                .buttonStyle(WarmPrimaryButtonStyle())
                .disabled(selectedGoals.isEmpty)
                .padding(.horizontal)
                .padding(.bottom, 24)
        }
    }
}

struct GoalGridItem: View {
    let goal: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(goal)
                .bodyFont()
                .padding()
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color(hex: "#ff9f68") : Color.white)
                .cornerRadius(12)
                .foregroundColor(isSelected ? Color.white : Color.primary)
                // Use a darker warm color (#b65f3b) for selected state, white otherwise. Invert text color for contrast.
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color(hex: "#ff9f68") : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                )
        }
        .animation(.easeInOut, value: isSelected)
    }
}

// MARK: - Notification Preferences Step (Trigger permission on toggle)
struct NotificationPreferencesStepView: View {
    @Binding var notificationsEnabled: Bool
    @Binding var notificationTime: String
    let onContinue: () -> Void

    @State private var selectedDate = Date()

    var body: some View {
        VStack(spacing: 28) {
            Text("Daily Quote Notifications")
                .headingFont()
            Toggle(isOn: $notificationsEnabled) {
                Text("Enable daily notifications")
                    .bodyFont()
            }
            .onChange(of: notificationsEnabled) { enabled in
                if enabled {
                    NotificationService.shared.requestAuthorization { _ in }
                }
            }
            // Show time picker only if notifications are enabled
            if notificationsEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Time:")
                        .bodyFont()
                    DatePicker("Select Time", selection: $selectedDate, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .onChange(of: selectedDate) { date in
                            notificationTime = Self.formatTime(date)
                        }
                }
                .padding(.horizontal)
            }
            Text("You can always change this in Settings. We respect your privacy and will never spam you.")
                .captionFont()
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Continue", action: onContinue)
                .buttonStyle(WarmPrimaryButtonStyle())
        }
        .padding(.horizontal)
        .onAppear {
            selectedDate = Self.parseTime(notificationTime)
        }
    }
    // Helper to format time string
    static func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    static func parseTime(_ time: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: time) ?? Date()
    }
}

// MARK: - Widget Intro Step (moved after preferences)
struct WidgetIntroStepView: View {
    let onContinue: () -> Void
    @State private var showInstructions = false
    var body: some View {
        VStack(spacing: 28) {
            // Widget preview or placeholder image
            Image("widget-preview-placeholder")
                .resizable()
                .scaledToFit()
                .frame(height: 80)
                .cornerRadius(16)
                .shadow(radius: 8)
                .padding(.bottom, 8)
            Text("Get daily quotes on your lock screen with the Whole widget.")
                .bodyFont()
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Install Widget") {
                showInstructions = true
            }
            .buttonStyle(WarmPrimaryButtonStyle())
        }
        .sheet(isPresented: $showInstructions) {
            WidgetInstallInstructionsSheet(onContinue: onContinue)
                .presentationDetents([.large]) // Always show full screen
        }
    }
}

// MARK: - Widget Install Instructions Sheet
/// Sheet shown when user taps Install Widget, with step-by-step guide and placeholder image
struct WidgetInstallInstructionsSheet: View {
    let onContinue: () -> Void
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack(spacing: 24) {
            Text("How to Add the Widget")
                .headingFont()
                .multilineTextAlignment(.center)
            // Placeholder for instructional image (replace with real image/animation as needed)
            Image("widget-instructions-placeholder")
                .resizable()
                .scaledToFit()
                .frame(height: 160)
                .cornerRadius(16)
                .shadow(radius: 8)
                .padding(.vertical)
            VStack(alignment: .leading, spacing: 12) {
                Text("1. Long-press on your home screen until the icons jiggle.")
                Text("2. Tap the '+' button in the top left corner.")
                Text("3. Search for 'Whole' in the widget gallery.")
                Text("4. Select your preferred widget size and tap 'Add Widget'.")
                Text("5. Place the widget where you like and tap 'Done'.")
            }
            .bodyFont()
            .padding(.horizontal)
            Button("Got it!") {
                presentationMode.wrappedValue.dismiss()
                onContinue()
            }
            .buttonStyle(WarmPrimaryButtonStyle())
            .padding(.top, 8)
        }
        .padding()
    }
}

// MARK: - Subscription/Trial Step
/// Presents the free trial offer with a clear call-to-action to start the trial.
struct SubscriptionIntroStepView: View {
    let onContinue: () -> Void
    @State private var trialReminder: Bool = true
    @StateObject private var paywallViewModel = PaywallViewModel()

    var body: some View {
        VStack(spacing: 28) {
            // Clearly present the free trial offer
            Text("Unlock Unlimited Quotes & Premium Features")
                .headingFont()
                .multilineTextAlignment(.center)
            VStack(alignment: .leading, spacing: 12) {
                Text("Experience the best of Whole with a free trial:")
                    .bodyFont()
                FeatureRow(text: "Unlimited inspirational quotes, every day")
                FeatureRow(text: "Bilingual content in English & Chinese")
                FeatureRow(text: "Personalized daily reminders")
                FeatureRow(text: "Exclusive premium categories")
                FeatureRow(text: "Priority support & early access to new features")
            }
            .padding(.horizontal)
            Text("Start a 7-day free trial to access all features. You will not be charged until the trial ends.")
                .bodyFont()
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Toggle(isOn: $trialReminder) {
                Text("Remind me before trial ends")
                    .bodyFont()
            }
            .padding(.horizontal)
            if let error = paywallViewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .bodyFont()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            if paywallViewModel.purchaseSuccess {
                Text("Subscription activated! Enjoy premium features.")
                    .foregroundColor(.green)
                    .bodyFont()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            Button(paywallViewModel.isProcessing ? "Processing..." : (paywallViewModel.errorMessage == "Unable to load subscription product." ? "Continue" : "Start Free Trial")) {
                if paywallViewModel.errorMessage == "Unable to load subscription product." {
                    onContinue()
                } else {
                    subscribe()
                }
            }
            .buttonStyle(WarmPrimaryButtonStyle())
            .disabled(paywallViewModel.isProcessing)
        }
        .padding(.horizontal)
    }
    private func subscribe() {
        paywallViewModel.startTrial()
        // If purchase is successful, call onContinue
        // Observe purchaseSuccess to trigger onContinue
        if paywallViewModel.purchaseSuccess {
            onContinue()
        } else {
            // Listen for changes to purchaseSuccess
            paywallViewModel.$purchaseSuccess
                .filter { $0 }
                .first()
                .sink { _ in onContinue() }
                .store(in: &paywallViewModel.cancellables)
        }
    }
}

/// Feature row for premium description
struct FeatureRow: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(Color(hex: "#ff9f68"))
                .font(.system(size: 18))
            Text(text)
                .bodyFont()
        }
    }
}

// MARK: - Preview
#if DEBUG
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(viewModel: OnboardingViewModel())
    }
}
#endif
