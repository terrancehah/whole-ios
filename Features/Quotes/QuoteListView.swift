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
        TabView(selection: $selectedIndex) {
            ForEach(enumeratedQuotesToShow, id: \.element.id) { idx, quote in
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
        NavigationView {
            ZStack(alignment: .bottom) {
                // Use extracted TabView for quotes
                if enumeratedQuotesToShow.isEmpty {
                    VStack(spacing: 24) {
                        Image(systemName: "quote.bubble")
                            .font(.system(size: 48))
                            .foregroundColor(ThemeManager.shared.selectedTheme.theme.cardBackground) // fallback, was accent
                        Text("No quotes available")
                            .headingFont(size: 20)
                            .foregroundColor(ThemeManager.shared.selectedTheme.theme.englishColor)
                        Text("Try again later or check your connection.")
                            .bodyFont(size: 15)
                            .multilineTextAlignment(.center)
                            .foregroundColor(ThemeManager.shared.selectedTheme.theme.chineseColor)
                    }
                    .padding()
                } else {
                    // Only show the quoteTabView (quote + actions now handled inside QuoteShareCardView)
                    quoteTabView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
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
            // Use centralized theme background color
            .background(ThemeManager.shared.selectedTheme.theme.background)
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
                .shadow(radius: 10)
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
