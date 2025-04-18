# Whole App Creation Roadmap

This document provides a step-by-step guide for developing the Whole app, from backend integration to launch. Follow these steps sequentially for a smooth and scalable development process.

---

## Step 1: Data Models & ViewModels — ✅ COMPLETED
**Objective:** Establish core data structures and logic.
- [`UserModel.swift`](../Models/UserModel.swift) defines the user profile, including subscription and trial fields, mapped to Supabase.
- [`SubscriptionModel.swift`](../Models/SubscriptionModel.swift) encapsulates subscription state and dates for robust premium logic.
- [`UserQuoteModel.swift`](../Models/UserQuoteModel.swift) supports user-generated quotes for future premium features.
- [`QuoteViewModel.swift`](../ViewModels/QuoteViewModel.swift) manages quote fetching, state, and error handling using Combine.
**Outcome:** The app has a complete, extensible foundation for all user, quote, and subscription data flows.

---

## Step 2: Backend Integration — ✅ COMPLETED
**Objective:** Connect the app to Supabase for real-time data, auth, and storage.
- [`SupabaseService.swift`](../Services/SupabaseService.swift) manages all database operations, including fetching quotes, liking/unliking, and retrieving user profiles.
- [`AuthService.swift`](../Services/AuthService.swift) provides robust user authentication, session management, and password reset, with published properties for reactive UI.
- All flows are well-documented, robust, and ready for integration with the rest of the app.
**Outcome:** The app is fully connected to Supabase, with secure authentication and real-time data sync for users and quotes.

---

## Step 3: Build Reusable UI Components — ✅ COMPLETED
**Objective:** Create modular UI for consistent user experience.
- [`QuoteCardView.swift`](../Components/QuoteCardView.swift) is a semantic, reusable card for displaying bilingual quotes, categories, and actions, with clear separation of concerns and preview support.
- [`CustomButton.swift`](../Components/CustomButton.swift) provides a flexible, consistent button used across all interactive UI.
- Both components are well-commented, follow best practices, and support rapid UI development across the app.
**Outcome:** The app has polished, reusable UI building blocks that ensure a consistent, maintainable user experience.

---

## Step 4: Main Quote Browsing Interface — ✅ COMPLETED
**Objective:** Enable users to browse and interact with quotes.
- [`QuoteListView.swift`](../Features/Quotes/QuoteListView.swift) provides a horizontally swipeable interface for browsing daily bilingual quotes.
- Integrates Like and Share actions, with clear visual feedback and premium gating logic.
- Enforces swipe limits for free users, and presents a paywall CTA and modal when limits are reached.
- Supports theming and robust error handling for a polished user experience.
**Outcome:** Users can browse, like, and share daily quotes, with premium logic and paywall gating fully integrated.

---

## Step 5: Complete Settings Sections — ✅ COMPLETED
**Objective:** Provide users with a full-featured settings experience.
- [`SettingsView.swift`](../Features/Settings/SettingsView.swift) is the central hub, integrating all settings sections and passing a reactive `UserProfileViewModel` to each for robust premium gating and paywall logic.
- [`CustomizationView.swift`](../Features/Settings/CustomizationView.swift) allows theme selection with premium gating and paywall integration.
- [`SubscriptionView.swift`](../Features/Settings/SubscriptionView.swift) displays plan, trial, and manage/upgrade options.
- [`ProfileView.swift`](../Features/Settings/ProfileView.swift) displays and allows editing of user info, including logout.
- [`WidgetSettingsView.swift`](../Features/Settings/WidgetSettingsView.swift) provides widget setup/help and premium customization options.
- [`NotificationSettingsView.swift`](../Features/Settings/NotificationSettingsView.swift) manages notification preferences.
- All sections are modular, ready for expansion, and provide a scalable, maintainable foundation for future settings features.
**Outcome:** Users can manage all aspects of their account, subscription, and app experience from a single, modern settings interface.

---

## Step 6: Sharing, Theming, and Paywall Polish — ✅ COMPLETED
**Objective:** Enhance user engagement and monetization.
- Sharing capabilities for quotes (native share sheet, social, etc.) are implemented and polished.
- Theming infrastructure is finalized; main UI responds to theme changes and premium themes are gated.
- Paywall presentation and premium gating are robust and consistent across all flows.
- Watermark logic for free users is implemented for shared images.
- All premium actions (theme, sharing, unlimited swipes, etc.) consistently trigger the paywall modal for free users.
- UI/UX polish: badges, borders, and feedback for gated features are visually consistent.
- All flows are tested for robustness and polish.
**Outcome:** The app provides a delightful, premium experience and is ready for broader testing.

---

## Step 7: Widget Development — ✅ COMPLETED (2025-04-18)
**Objective:** Deliver quotes directly to users’ lock screen/standby.
- Widget displays the quote most recently shown on the main interface.
- Logic implemented in `QuoteListView.swift` to save the currently displayed quote to App Group UserDefaults whenever the user swipes or launches the app.
- Widget reads this value and updates accordingly.
- Ensures a consistent and familiar experience between app and widget.
- All technical details and code comments updated for maintainability.
**Outcome:** Widget and app remain in sync, and the integration is robust for MVP.

---

## Step 8: Onboarding Flow — ⬜ TODO
**Objective:** Guide new users and collect preferences.
- Build `OnboardingView.swift` (welcome, widget intro, category selection, etc.).
- Implement `OnboardingViewModel.swift` for onboarding logic.
**Outcome:** New users are smoothly introduced and their preferences are captured.

---

## Step 9: Paywall & Subscription Logic — ⬜ TODO
**Objective:** Monetize via subscriptions and manage access.
- Implement `PaywallView.swift` for subscription options/free trial.
- Develop `PaywallViewModel.swift` for StoreKit integration and subscription logic.
- Premium gating for all features (unlimited swipes, theme/font customization) is now enforced using UserProfile.subscriptionStatus and trialEndDate.
- Paywall modal is triggered for free users at the swipe limit or when accessing premium features.
- All logic is model-driven and robust against backend changes.
**Outcome:** Users can subscribe for unlimited/premium features.

---

## Step 10: Favorites Feature — ⬜ TODO
**Objective:** Enable saving and revisiting favorite quotes.
- Build `FavoritesView.swift` to display saved quotes.
- Create `FavoritesViewModel.swift` for managing favorites (persisted via Supabase).
**Outcome:** Users can save and revisit liked quotes.

---

## Step 11: User-Generated Quotes (Premium) — ⬜ TODO
**Objective:** Let premium users create and submit their own quotes.
- Build `UserQuoteEditorView.swift` for quote creation.
- Add moderation/approval flow for submitted quotes.
**Outcome:** Premium users can contribute content, increasing engagement and value.

---

## Step 12: Notifications & Analytics — ⬜ TODO
**Objective:** Enhance engagement and gather usage insights.
- Set up `NotificationService.swift` for daily quote notifications (user-scheduled).
- Implement `AnalyticsService.swift` for tracking user behavior.
**Outcome:** Users receive daily quotes and analytics provide actionable insights.

---

## Step 13: Theming & Styling — ⬜ TODO
**Objective:** Ensure a cohesive, attractive design.
- Use `Theme.swift` for colors, fonts, and appearance.
- Apply consistent theming across all screens and components.
**Outcome:** The app has a consistent, appealing look.

---

## Step 14: Testing & Quality Assurance — ⬜ TODO
**Objective:** Ensure reliability and catch bugs before release.
- Write unit tests for critical models/services (e.g., `QuoteViewModel.swift`, `AuthService.swift`).
- Create UI tests for key flows (onboarding, paywall, quote browsing).
**Outcome:** The app is stable and ready for App Store submission.

---

## Step 15: Final Review & Launch — ⬜ TODO
**Objective:** Prepare for App Store submission and launch.
- Review all features, polish UI, and fix outstanding bugs.
- Prepare App Store assets, descriptions, and screenshots.
- Submit for review and monitor analytics post-launch.
**Outcome:** Whole is available for users, with a plan for post-launch improvements.

---

### Progress & Next Steps (as of 2025-04-18)

- All foundational steps through settings are ✅ COMPLETED.
- **Step 6: Sharing, Theming, and Paywall Polish** is now ✅ COMPLETED.
- **Step 7: Widget Development** is now ✅ COMPLETED.
- Next: Complete onboarding, favorites, and other features.

---

> For detailed guidance on each step, refer to the respective documentation files in `/docs`.
