// QuoteListView.swift
// Displays a horizontally swipeable list of quote cards with like/share, swipe limit, and theming.

import SwiftUI
import UIKit

/// Main interface for browsing bilingual quotes with horizontal swipe, like/share, and daily limit logic.
struct QuoteListView: View {
    @ObservedObject var viewModel: QuoteViewModel
    @ObservedObject var userProfile: UserProfileViewModel
    @State private var selectedIndex: Int = 0
    @State private var showLikePopup: Bool = false
    @State private var showLimitPopup: Bool = false
    @State private var showPaywall: Bool = false
    @State private var shake: Bool = false
    @State private var shareItem: ShareItem? = nil

    // Gating logic: Only premium users (trial or paid) can swipe unlimited
    // This logic checks the user's subscription status and trial end date to determine premium access
    var isPremiumUser: Bool {
        let now = Date()
        // If user is 'free', only allow premium if trial is still active
        if userProfile.user.subscriptionStatus == "free" {
            if let trialEnd = userProfile.user.trialEndDate {
                // User is premium if trial is active
                return trialEnd > now
            }
            // No trial, not premium
            return false
        }
        // Any other subscription status is premium
        return true
    }

    // Computed property to provide enumerated quotes for display, breaking up complex expressions for compiler performance
    private var enumeratedQuotesToShow: [(offset: Int, element: Quote)] {
        let quotesToShow = Array(viewModel.quotes.prefix(isPremiumUser ? viewModel.quotes.count : viewModel.swipeLimit))
        return Array(quotesToShow.enumerated())
    }

    // Extracted TabView for quotes to reduce complexity in main body and help the compiler
    private var quoteTabView: some View {
        let _ = print("[DEBUG] QuoteListView: quoteTabView - enumeratedQuotesToShow.count = \(enumeratedQuotesToShow.count)")
        return TabView(selection: $selectedIndex) {
            ForEach(enumeratedQuotesToShow, id: \.element.id) { idx, quote in
                // --- Print statement remains for debugging ---
                let _ = print("[DEBUG] QuoteListView: quoteTabView - ForEach: idx = \(idx), quoteID = \(quote.id)")
                // --- ORIGINAL CODE RESTORED ---
                QuoteShareCardView(
                    quote: quote,
                    showWatermark: !isPremiumUser,
                    viewModel: viewModel,
                    selfShareImage: { image in
                        self.shareItem = ShareItem(image: image)
                    },
                    showLikePopup: { show in
                        self.showLikePopup = show
                    }
                )
                    .tag(idx)
                    .modifier(ShakeEffect(shakes: shake && idx == 0 ? 2 : 0)) // Animate shake for first card only
                    // Disable cards beyond the limit for free users
                    .disabled(!isPremiumUser && viewModel.reachedSwipeLimit && idx >= viewModel.swipeLimit)
            }
        }
        // Remove the horizontal scroll indicator (dots)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onChange(of: selectedIndex) { newIndex in
            // Save the currently displayed quote for the widget whenever the user swipes to a new quote.
            if viewModel.quotes.indices.contains(newIndex) {
                let currentQuote = viewModel.quotes[newIndex]
                // Call the new saveQuoteForWidget method on the viewModel
                viewModel.saveQuoteForWidget(currentQuote)
            }
            // If a free user hits the swipe limit, show limit popup and paywall modal
            if !isPremiumUser && newIndex >= viewModel.swipeLimit {
                showLimitPopup = true
                showPaywall = true
                viewModel.showPaywallCTA = true
            }
        }
        .onAppear {
            // Save the initial quote for the widget when the view appears.
            if viewModel.quotes.indices.contains(selectedIndex) {
                let currentQuote = viewModel.quotes[selectedIndex]
                viewModel.saveQuoteForWidget(currentQuote)
            }
            // Trigger shake animation for the first card
            if selectedIndex == 0 {
                withAnimation(Animation.default.delay(0.5)) {
                    shake = true
                }
                // Reset shake after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    shake = false
                }
            }
        }
        .animation(.easeInOut, value: selectedIndex)
        .padding(.bottom, 60)
    }

    var body: some View {
        let _ = print("[DEBUG] QuoteListView Body (VM ID: \(viewModel.instanceID.uuidString)): isLoading = \(viewModel.isLoading), errorMessage = \(viewModel.errorMessage ?? "nil"), quotes.count = \(viewModel.quotes.count)")
        let _ = print("[DEBUG] QuoteListView Body (VM ID: \(viewModel.instanceID.uuidString)): userProfile.isSubStatus = \(userProfile.user.subscriptionStatus), isPremiumUser = \(isPremiumUser), swipeLimit = \(viewModel.swipeLimit), enumeratedQuotesToShow.count = \(enumeratedQuotesToShow.count)")

        NavigationView {
            ZStack(alignment: .bottom) {
                // Use the theme's background color, ignoring safe areas to fill the screen
                ThemeManager.shared.selectedTheme.theme.background
                    .ignoresSafeArea()
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                // Use extracted TabView for quotes
                quoteTabView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                // Paywall CTA button for free users only, appears when limit is hit
                if viewModel.showPaywallCTA && !isPremiumUser {
                    // Replace paywall CTA button with CustomButton for default shadow
                    CustomButton(label: "Unlock Unlimited Quotes", systemImage: nil, action: { showPaywall = true })
                        .padding(.bottom, 24)
                }
            }
            // Like popup
            .overlay(
                Group {
                    if showLikePopup {
                        PopupView(message: "Liked!")
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                    showLikePopup = false
                                }
                            }
                    }
                }, alignment: .bottom
            )
            // Swipe limit popup for free users
            .overlay(
                Group {
                    if showLimitPopup {
                        PopupView(message: "Daily swipe limit reached.")
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    showLimitPopup = false
                                }
                            }
                    }
                }, alignment: .bottom
            )
            // Share sheet
            .sheet(item: $shareItem) { item in
                ShareSheet(image: item.image)
            }
            // Paywall modal appears when triggered by gating logic
            .sheet(isPresented: $showPaywall) {
                PaywallView(viewModel: PaywallViewModel())
            }

            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            print("[DEBUG] QuoteListView appeared. isPreferencesLoaded: \(userProfile.isPreferencesLoaded), selectedCategories: \(userProfile.userPreferences.selectedCategories)")
            if userProfile.isPreferencesLoaded && !userProfile.userPreferences.selectedCategories.isEmpty {
                print("[DEBUG] Triggering fetchQuotes from .onAppear")
                viewModel.fetchQuotes(selectedCategories: userProfile.userPreferences.selectedCategories)
            }
        }
        .onChange(of: userProfile.isPreferencesLoaded) { isLoaded in
            print("[DEBUG] isPreferencesLoaded changed: \(isLoaded). selectedCategories: \(userProfile.userPreferences.selectedCategories)")
            if isLoaded && !userProfile.userPreferences.selectedCategories.isEmpty {
                print("[DEBUG] Triggering fetchQuotes from .onChange isPreferencesLoaded")
                viewModel.fetchQuotes(selectedCategories: userProfile.userPreferences.selectedCategories)
            }
        }
        .onChange(of: userProfile.userPreferences.selectedCategories) { categories in
            print("[DEBUG] selectedCategories changed: \(categories). isPreferencesLoaded: \(userProfile.isPreferencesLoaded)")
            if userProfile.isPreferencesLoaded && !categories.isEmpty {
                print("[DEBUG] Triggering fetchQuotes from .onChange selectedCategories")
                viewModel.fetchQuotes(selectedCategories: categories)
            }
        }
    }
    
    // MARK: - ShareItem for Identifiable conformance
    struct ShareItem: Identifiable {
        let id = UUID()
        let image: UIImage
    }

    // MARK: - UIKit Share Sheet Wrapper for SwiftUI
    /// Minimal, native wrapper for sharing a UIImage using UIActivityViewController
    struct ShareSheet: UIViewControllerRepresentable {
        let image: UIImage
        func makeUIViewController(context: Context) -> UIActivityViewController {
            // Share UIImage directly to restore all photo actions in the share sheet
            let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            return activityVC
        }
        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    }

    // MARK: - PopupView for native-style feedback
    struct PopupView: View {
        let message: String
        var body: some View {
            Text(message)
                .captionFont(size: 15) // Use caption font for popups
                .padding(.vertical, 12)
                .padding(.horizontal, 32)
                .background(BlurView(style: .systemMaterial))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 2)
                .padding(.bottom, 40)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - BlurView for Popup background
    struct BlurView: UIViewRepresentable {
        let style: UIBlurEffect.Style
        func makeUIView(context: Context) -> UIVisualEffectView {
            UIVisualEffectView(effect: UIBlurEffect(style: style))
        }
        func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
    }

    // MARK: - ShakeEffect Modifier
    /// A view modifier that applies a horizontal shake animation.
    struct ShakeEffect: GeometryEffect {
        var shakes: Int
        var animatableData: CGFloat {
            get { CGFloat(shakes) }
            set { shakes = Int(newValue) }
        }
        func effectValue(size: CGSize) -> ProjectionTransform {
            let translation = 8 * sin(animatableData * .pi * 2)
            return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
        }
    }

    // MARK: - Preview
    struct QuoteListView_Previews: PreviewProvider {
        static var previews: some View {
            QuoteListView(viewModel: QuoteViewModel.preview, userProfile: UserProfileViewModel.preview)
        }
    }
}
