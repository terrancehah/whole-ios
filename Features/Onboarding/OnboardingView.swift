// OnboardingView.swift
// Displays the onboarding flow: welcome, widget intro, preferences, notification preferences, and subscription intro.

import SwiftUI

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
                                .padding(.leading)
                        }
                    }
                    Spacer()
                    // Show skip button if applicable
                    if showSkip(for: viewModel.currentStep) {
                        Button("Skip") {
                            skipCurrentStep()
                        }
                        .font(.headline)
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
                    CategoriesStepView(selectedCategories: $viewModel.selectedCategories, allCategories: viewModel.allCategories, onContinue: viewModel.nextStep)
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
        case .categories, .name, .goals, .subscriptionIntro:
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
                .font(.largeTitle).bold()
            Text("Your daily dose of inspiration in English and Chinese.")
                .multilineTextAlignment(.center)
            Button("Continue", action: onContinue)
                .buttonStyle(.borderedProminent)
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
                .font(.title2).bold()
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
                .buttonStyle(.borderedProminent)
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
                .fontWeight(.medium)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.accentColor.opacity(0.2) : Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                )
                .cornerRadius(12)
                .foregroundColor(isSelected ? Color.accentColor : Color.primary)
        }
        .animation(.easeInOut, value: isSelected)
    }
}

// MARK: - Name Step
struct NameStepView: View {
    @Binding var name: String
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            Text("What's your name?")
                .font(.title2).bold()
            TextField("Enter your name (optional)", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            Button("Continue", action: onContinue)
                .buttonStyle(.borderedProminent)
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
        VStack(spacing: 28) {
            Text("Select Your Goals")
                .font(.title2).bold()
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
            Button("Continue", action: onContinue)
                .buttonStyle(.borderedProminent)
                .disabled(selectedGoals.isEmpty)
        }
        .padding(.horizontal)
    }
}

struct GoalGridItem: View {
    let goal: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(goal)
                .fontWeight(.medium)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.accentColor.opacity(0.2) : Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                )
                .cornerRadius(12)
                .foregroundColor(isSelected ? Color.accentColor : Color.primary)
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
                .font(.title2).bold()
            Toggle(isOn: $notificationsEnabled) {
                Text("Enable daily notifications")
            }
            .onChange(of: notificationsEnabled) { enabled in
                if enabled {
                    NotificationService.shared.requestAuthorization { _ in }
                }
            }
            if notificationsEnabled {
                DatePicker("Notification Time", selection: $selectedDate, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .onChange(of: selectedDate) { date in
                        notificationTime = Self.formatTime(date)
                    }
            }
            Text("You can always change this in Settings. We respect your privacy and will never spam you.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Continue", action: onContinue)
                .buttonStyle(.borderedProminent)
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
    var body: some View {
        VStack(spacing: 28) {
            Image(systemName: "rectangle.stack.fill.badge.plus")
                .resizable().scaledToFit().frame(height: 80)
                .foregroundColor(.accentColor)
            Text("Get daily quotes on your lock screen with the Whole widget.")
                .multilineTextAlignment(.center)
            Button("Install Widget", action: onContinue)
                .buttonStyle(.borderedProminent)
            Button("Later", action: onContinue)
                .buttonStyle(.bordered)
        }
    }
}

// MARK: - Subscription/Trial Step
struct SubscriptionIntroStepView: View {
    let onContinue: () -> Void
    @State private var trialReminder: Bool = true
    var body: some View {
        VStack(spacing: 28) {
            Text("Unlock Unlimited Quotes & Premium Features")
                .font(.title2).bold()
                .multilineTextAlignment(.center)
            Text("Start a 7-day free trial to access all features. You will not be charged until the trial ends. We'll remind you before your trial expires.")
                .multilineTextAlignment(.center)
            Toggle(isOn: $trialReminder) {
                Text("Remind me before trial ends")
            }
            .padding(.horizontal)
            HStack {
                Button("Skip Trial") {
                    onContinue() // Skips trial
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Start Free Trial", action: onContinue)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(.horizontal)
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
