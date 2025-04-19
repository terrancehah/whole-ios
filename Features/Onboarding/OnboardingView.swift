// OnboardingView.swift
// Displays the onboarding flow: welcome, widget intro, preferences, and subscription intro.

import SwiftUI

/// Main onboarding view presenting a multi-step onboarding flow.
struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack {
            switch viewModel.currentStep {
            case .welcome:
                WelcomeStepView(onContinue: viewModel.nextStep)
            case .widgetIntro:
                WidgetIntroStepView(onContinue: viewModel.nextStep)
            case .preferences:
                PreferencesStepView(
                    selectedCategories: $viewModel.selectedCategories,
                    name: $viewModel.name,
                    gender: $viewModel.gender,
                    goals: $viewModel.goals,
                    allCategories: viewModel.allCategories,
                    allGenders: viewModel.allGenders,
                    allGoals: viewModel.allGoals,
                    onContinue: viewModel.nextStep,
                    onSkipName: viewModel.skipName,
                    onSkipGender: viewModel.skipGender,
                    onSkipGoals: viewModel.skipGoals
                )
            case .subscriptionIntro:
                SubscriptionIntroStepView(onContinue: viewModel.nextStep)
            case .completed:
                // Optionally navigate to main app interface
                Text("Onboarding Complete!").font(.title).padding()
            }
            // Show loading and error states
            if viewModel.isLoading {
                ProgressView("Saving...").padding()
            }
            if let error = viewModel.errorMessage {
                Text(error).foregroundColor(.red).padding()
            }
        }
        .animation(.easeInOut, value: viewModel.currentStep)
        .padding()
        .background(Color(.systemBackground))
        .edgesIgnoringSafeArea(.all)
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

/// Widget intro step: Explains widget feature.
struct WidgetIntroStepView: View {
    let onContinue: () -> Void
    var body: some View {
        VStack(spacing: 24) {
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

/// Preferences step: Collects categories, name, gender, and goals.
struct PreferencesStepView: View {
    @Binding var selectedCategories: Set<QuoteCategory>
    @Binding var name: String
    @Binding var gender: String
    @Binding var goals: Set<String>
    let allCategories: [QuoteCategory]
    let allGenders: [String]
    let allGoals: [String]
    let onContinue: () -> Void
    let onSkipName: () -> Void
    let onSkipGender: () -> Void
    let onSkipGoals: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Tell us about yourself")
                    .font(.title2).bold()
                // Categories
                VStack(alignment: .leading) {
                    Text("Preferred Categories").font(.headline)
                    ForEach(allCategories, id: \.self) { category in
                        Toggle(category.displayName, isOn: Binding(
                            get: { selectedCategories.contains(category) },
                            set: { isOn in
                                if isOn { selectedCategories.insert(category) }
                                else { selectedCategories.remove(category) }
                            }
                        ))
                    }
                }
                // Name
                VStack(alignment: .leading) {
                    Text("Name (Optional)").font(.headline)
                    HStack {
                        TextField("Enter your name", text: $name)
                        Button("Skip", action: onSkipName)
                            .font(.caption)
                    }
                }
                // Gender
                VStack(alignment: .leading) {
                    Text("Gender (Optional)").font(.headline)
                    Picker("Gender", selection: $gender) {
                        ForEach(allGenders, id: \.self) { gender in
                            Text(gender).tag(gender)
                        }
                    }
                    .pickerStyle(.segmented)
                    Button("Skip", action: onSkipGender)
                        .font(.caption)
                }
                // Goals
                VStack(alignment: .leading) {
                    Text("Goals (Optional)").font(.headline)
                    ForEach(allGoals, id: \.self) { goal in
                        Toggle(goal, isOn: Binding(
                            get: { goals.contains(goal) },
                            set: { isOn in
                                if isOn { goals.insert(goal) }
                                else { goals.remove(goal) }
                            }
                        ))
                    }
                    Button("Skip", action: onSkipGoals)
                        .font(.caption)
                }
                Button("Continue", action: onContinue)
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}

/// Subscription intro step: Introduces premium features and transitions to paywall.
struct SubscriptionIntroStepView: View {
    let onContinue: () -> Void
    var body: some View {
        VStack(spacing: 24) {
            Text("Unlock Unlimited Quotes & Premium Features")
                .font(.title2).bold()
                .multilineTextAlignment(.center)
            Text("Start a 7-day free trial to access all features.")
                .multilineTextAlignment(.center)
            Button("Continue", action: onContinue)
                .buttonStyle(.borderedProminent)
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
