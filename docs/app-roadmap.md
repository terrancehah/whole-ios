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
- Sharing capabilities for quotes are implemented and polished:
    - [`QuoteShareCardView.swift`](../Features/Quotes/QuoteShareCardView.swift): Renders a quote as a shareable image, applies watermark for free users, and uses current theme styling.
    - [`QuoteImageGenerator.swift`](../Features/Sharing/QuoteImageGenerator.swift): Utility for generating shareable images (UIImage) from quotes, ensures watermark logic for free users.
- Theming infrastructure is finalized and robust:
    - [`ThemeManager.swift`](../Features/Settings/ThemeManager.swift): Centralized theme management, defines all themes, and provides global state for theme selection.
    - [`CustomizationView.swift`](../Features/Settings/CustomizationView.swift): UI for theme selection, premium gating, and paywall integration.
- Paywall presentation and premium gating are consistent across all flows:
    - [`PaywallView.swift`](../Features/Paywall/PaywallView.swift): Modern paywall UI for trial, subscription, and upgrade, with clear call-to-action and robust logic.
    - [`PaywallViewModel.swift`](../Features/Paywall/PaywallViewModel.swift): Handles StoreKit integration and subscription logic (to be completed in Step 9).
    - Premium gating logic is enforced in all relevant files (e.g., `QuoteListView.swift`, `CustomizationView.swift`, `QuoteImageGenerator.swift`).
- Watermark logic for free users is implemented for all shared images.
- All premium actions (theme, sharing, unlimited swipes, etc.) consistently trigger the paywall modal for free users.
- UI/UX polish: badges, borders, feedback for gated features, and previews for both free and premium states are visually consistent and robust.
**Outcome:** The app provides a delightful, premium experience and is ready for broader testing.

---

## Step 7: Widget Development — ✅ COMPLETED
**Objective:** Deliver quotes directly to users’ lock screen/standby.
- [`WidgetEntry.swift`](../Widget/WidgetEntry.swift): Defines `QuoteWidgetEntry` and `QuoteWidgetProvider` for the widget’s timeline, loads the daily quote and theme from App Group UserDefaults (`group.com.wholeapp.shared`), and provides fallback logic if no quote is set.
- [`QuoteListView.swift`](../Features/Quotes/QuoteListView.swift): On every swipe or launch, saves the currently displayed quote to App Group UserDefaults for widget consumption, ensuring widget and app remain in sync.
- [`WidgetSettingsView.swift`](../Features/Settings/WidgetSettingsView.swift): Provides user-facing settings/help for the widget (MVP: displays most recent quote, no category selection yet).
- Widget timeline updates once per day for fresh content.
- Widget loads and applies the selected theme from shared storage.
- All technical details and code comments are up to date for maintainability and future extensibility.
**Outcome:** Widget and app remain in sync, the widget always displays the most recently shown quote, and the integration is robust for MVP.

---

## Step 8: Onboarding Flow — ✅ COMPLETED
**Objective:** Guide new users and collect preferences.
- Build `OnboardingView.swift` (welcome, widget intro, category selection, etc.).
- Implement `OnboardingViewModel.swift` for onboarding logic.
**Outcome:** New users are smoothly introduced and their preferences are captured.

---

## Step 9: Paywall & Subscription Logic — ✅ COMPLETED
**Objective:** Monetize via subscriptions and manage access.
- Implemented `PaywallView.swift` for subscription options/free trial.
- Developed `PaywallViewModel.swift` for StoreKit integration and subscription logic (stubs in place, ready for StoreKit 2).
- Premium gating for all features (unlimited swipes, theme/font customization, watermark-free images) is enforced using `UserProfile.subscriptionStatus` and `trialEndDate`.
- Paywall modal is triggered for free users at the swipe limit or when accessing premium features.
- All logic is model-driven, robust against backend changes, and clearly documented in the codebase.
**Outcome:** Users can subscribe for unlimited/premium features. Premium gating and paywall logic are fully implemented and commented for maintainability.

---

## Step 10: Favorites Feature — ✅ COMPLETED
**Objective:** Enable saving and revisiting favorite quotes.
- Built `FavoritesView.swift` to display saved quotes.
- Created `FavoritesViewModel.swift` for managing favorites (persisted via Supabase `LikedQuotes` table).
- Integrated Favorites as a dedicated tab in the main TabView navigation.
- All logic is robust, model-driven, and clearly commented.
**Outcome:** Users can save and revisit liked quotes. Favorites are synced in real time and easy to maintain.

---

## Step 11: User-Generated Quotes (Premium) — ✅ COMPLETED (2025-04-21)
**Objective:** Let premium users create and submit their own quotes.
- Implemented `UserQuoteEditorView.swift` with a modern, minimal UI for submitting bilingual quotes.
- The editor uses soft backgrounds, pastel chips, and robust validation for a delightful UX.
- Quotes are saved to the `userquotes` table in Supabase.
- Moderation/approval logic is planned for future versions.
**Outcome:** Premium users can now contribute original quotes, increasing engagement and value.

---

## Step 12: Notifications & Analytics — ⬜ IN PROGRESS
**Objective:** Enhance engagement and gather usage insights.
- Set up `NotificationService.swift` for daily quote notifications (user-scheduled, permission-aware).
- Implement `SupabaseService.swift` update methods for notification preferences (partial updates for `notificationsEnabled` and `notificationTime`).
- Integrate notification preference UI into onboarding and settings flows (toggle, time picker, permission request).
- All changes are robust, model-driven, and clearly commented.
**Outcome:** Users receive daily quotes at their chosen time; notification preferences are seamlessly managed and synced.

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

### Progress & Next Steps (as of 2025-04-21)

- All foundational steps through settings are ✅ COMPLETED.
- **Step 6: Sharing, Theming, and Paywall Polish** is now ✅ COMPLETED.
- **Step 7: Widget Development** is now ✅ COMPLETED.
- **Step 8: Onboarding Flow** is now ✅ DONE.
- **Step 9: Paywall & Subscription Logic** is now ✅ COMPLETE.
- **Step 10: Favorites Feature** is now ✅ COMPLETE.
- **Step 11: User-Generated Quotes (Premium)** is now ✅ COMPLETE.
- Next: Complete onboarding, user-generated quotes, and other features.

---

> For detailed guidance on each step, refer to the respective documentation files in `/docs`.
