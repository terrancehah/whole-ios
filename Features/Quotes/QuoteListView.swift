// QuoteListView.swift
// Displays a horizontally swipeable list of quote cards with like/share, swipe limit, and theming.

import SwiftUI

/// Main interface for browsing bilingual quotes with horizontal swipe, like/share, and daily limit logic.
struct QuoteListView: View {
    @ObservedObject var viewModel: QuoteViewModel
    @ObservedObject var userProfile: UserProfileViewModel
    @State private var selectedIndex: Int = 0
    @State private var showLikePopup: Bool = false
    @State private var showLimitPopup: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var shareImage: UIImage? = nil
    @State private var showPaywall: Bool = false
    @State private var shake: Bool = false

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
                QuoteShareCardView(quote: quote)
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
                    // Ensure the TabView fills the entire height and width of the screen
                    quoteTabView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                // (Removed bottom bar star/settings buttons as requested)

                // Bottom-center icon-only heart and share buttons (no shadow, no bar)
                VStack {
                    Spacer()
                    HStack(spacing: 48) {
                        // Share button
                        Button(action: {
                            // Check if selectedIndex is within bounds before accessing enumeratedQuotesToShow
                            if selectedIndex < enumeratedQuotesToShow.count {
                                let currentQuote = enumeratedQuotesToShow[selectedIndex].element
                                if let shareImage = viewModel.generateShareImage(for: currentQuote) {
                                    self.shareImage = shareImage
                                    self.showShareSheet = true
                                }
                            }
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 28, weight: .regular))
                                .foregroundColor(.primary)
                                .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
                        }
                        // Heart button
                        Button(action: {
                            // Check if selectedIndex is within bounds before accessing enumeratedQuotesToShow
                            if selectedIndex < enumeratedQuotesToShow.count {
                                let currentQuote = enumeratedQuotesToShow[selectedIndex].element
                                if viewModel.isLiked(quote: currentQuote) {
                                    viewModel.unlike(quote: currentQuote)
                                } else {
                                    viewModel.like(quote: currentQuote)
                                    showLikePopup = true
                                }
                            }
                        }) {
                            // Only show filled heart if current quote is liked and selectedIndex is within bounds
                            Image(systemName: (selectedIndex < enumeratedQuotesToShow.count && viewModel.isLiked(quote: enumeratedQuotesToShow[selectedIndex].element)) ? "heart.fill" : "heart")
                                .font(.system(size: 28, weight: .regular))
                                .foregroundColor(.primary)
                                .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.bottom, 36)
                }

                // Paywall CTA button for free users only, appears when limit is hit
                if viewModel.showPaywallCTA && !isPremiumUser {
                    // Replace paywall CTA button with CustomButton for default shadow
                    CustomButton(label: "Unlock Unlimited Quotes", systemImage: nil, action: { showPaywall = true })
                        .padding(.bottom, 24)
                }
            }
            // No background color here; let parent (RootAppView) show through
            .navigationBarTitleDisplayMode(.inline)
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
            // Remove error popup: do not show error messages to the user
            // Share sheet (not used here, but left for future extensibility)
            .sheet(isPresented: $showShareSheet) {
                if let shareImage = shareImage {
                    ShareSheet(activityItems: [shareImage])
                }
            }
            // Paywall modal appears when triggered by gating logic
            .sheet(isPresented: $showPaywall) {
                PaywallView(viewModel: PaywallViewModel())
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
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

// MARK: - ShareSheet Wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
