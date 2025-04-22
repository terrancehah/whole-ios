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
                    // Disable cards beyond the limit for free users
                    .disabled(!isPremiumUser && viewModel.reachedSwipeLimit && idx >= viewModel.swipeLimit)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .onChange(of: selectedIndex) { newIndex in
            // Save the currently displayed quote for the widget whenever the user swipes to a new quote.
            if viewModel.quotes.indices.contains(newIndex) {
                let currentQuote = viewModel.quotes[newIndex]
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
        }
        .animation(.easeInOut, value: selectedIndex)
        .padding(.bottom, 60)
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // Use extracted TabView for quotes
                quoteTabView

                // Paywall CTA button for free users only, appears when limit is hit
                if viewModel.showPaywallCTA && !isPremiumUser {
                    Button(action: { showPaywall = true }) {
                        Text("Unlock Unlimited Quotes")
                            .fontWeight(.bold)
                            .padding()
                            .background(Color(.systemBackground))
                            .foregroundColor(Color.accentColor)
                            .cornerRadius(12)
                            .shadow(color: Color.primary.opacity(0.15), radius: 10, x: 0, y: 4)
                            // Animate CTA when popup is shown
                            .scaleEffect(showLimitPopup ? 1.1 : 1.0)
                            .animation(.spring(), value: showLimitPopup)
                    }
                    .padding(.bottom, 24)
                }

                // Retry button for errors
                if let error = viewModel.errorMessage {
                    VStack {
                        Text(error)
                            .foregroundColor(.red)
                        Button("Retry") {
                            viewModel.retryFetchQuotes()
                        }
                        .padding(.top, 4)
                    }
                    .padding()
                    .background(Color(.systemBackground).opacity(0.95))
                    .cornerRadius(10)
                    .shadow(radius: 6)
                }
            }
            .background(ThemeManager.shared.selectedTheme.theme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: viewModel.showThemeSwitcher) {
                        Image(systemName: "paintbrush")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.showSettings) {
                        Image(systemName: "gearshape")
                    }
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
            .font(.subheadline)
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

// MARK: - Preview
struct QuoteListView_Previews: PreviewProvider {
    static var previews: some View {
        QuoteListView(viewModel: QuoteViewModel.preview, userProfile: UserProfileViewModel.preview)
    }
}
