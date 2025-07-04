# Whole App Creation Roadmap

This document provides a step-by-step guide for developing the Whole app, from backend integration to launch. Follow these steps sequentially for a smooth and scalable development process.

---

## Step 1: Data Models & ViewModels — 
**Objective:** Establish core data structures and logic.
- [`UserModel.swift`](../Models/UserModel.swift) defines the user profile, including subscription and trial fields, mapped to Supabase.
- [`SubscriptionModel.swift`](../Models/SubscriptionModel.swift) encapsulates subscription state and dates for robust premium logic.
- [`UserQuoteModel.swift`](../Models/UserQuoteModel.swift) supports user-generated quotes for future premium features.
- [`QuoteViewModel.swift`](../ViewModels/QuoteViewModel.swift) manages quote fetching, state, and error handling using Combine.
**Outcome:** The app has a complete, extensible foundation for all user, quote, and subscription data flows.

---

## Step 2: Backend Integration — 
**Objective:** Connect the app to Supabase for real-time data, auth, and storage.
- [`SupabaseService.swift`](../Services/SupabaseService.swift) manages all database operations, including fetching quotes, liking/unliking, and retrieving user profiles.
- [`AuthService.swift`](../Services/AuthService.swift) provides robust user authentication, session management, and password reset, with published properties for reactive UI.
- All flows are well-documented, robust, and ready for integration with the rest of the app.
- Anonymous account email is now set to `NULL`, not a placeholder, for all anonymous users. This prevents duplicate key errors and matches the latest onboarding logic.
- Quotes table `categories` column is now a Postgres `text[]` array, not a JSON string. All quoting, importing, and decoding logic aligns with this format.
- CSV import for quotes uses Postgres array syntax for the categories column.
**Outcome:** The app is fully connected to Supabase, with secure authentication and real-time data sync for users and quotes.

---

## Step 3: Build Reusable UI Components — 
**Objective:** Create modular UI for consistent user experience.
- [`QuoteCardView.swift`](../Components/QuoteCardView.swift) is a semantic, reusable card for displaying bilingual quotes, categories, and actions, with clear separation of concerns and preview support.
- [`CustomButton.swift`](../Components/CustomButton.swift) provides a flexible, consistent button used across all interactive UI.
- Both components are well-commented, follow best practices, and support rapid UI development across the app.
- UI: QuoteListView fills the screen, all buttons have a corner radius of 12 and consistent shadows, Chinese text uses a lighter color.
**Outcome:** The app has polished, reusable UI building blocks that ensure a consistent, maintainable user experience.

---

## Step 4: Main Quote Browsing Interface — 
**Objective:** Enable users to browse and interact with quotes.
- [`QuoteListView.swift`](../Features/Quotes/QuoteListView.swift) provides a horizontally swipeable interface for browsing daily bilingual quotes.
- Integrates Like and Share actions, with clear visual feedback and premium gating logic.
- Enforces swipe limits for free users, and presents a paywall CTA and modal when limits are reached.
- Supports theming and robust error handling for a polished user experience.
- Error popups for backend issues are now suppressed unless relevant.
**Outcome:** Users can browse, like, and share daily quotes, with premium logic and paywall gating fully integrated.

---

## Step 5: Complete Settings Sections — 
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

## Step 6: Sharing, Theming, and Paywall Polish — 
**Objective:** Enhance user engagement and monetization.
- Sharing capabilities for quotes are implemented and polished:
    - [`QuoteShareCardView.swift`](../Features/Quotes/QuoteShareCardView.swift): Renders a quote as a shareable image, applies watermark for free users, and uses current theme styling.
    - [`QuoteImageGenerator.swift`](../Features/Sharing/QuoteImageGenerator.swift): Utility for generating shareable images (UIImage) from quotes, ensures watermark logic for free users.
- Theming infrastructure is finalized and robust:
    - The default theme, Serene Minimalism, now uses a warm "leah valencia" color palette: background #ffeedf, card #ffd1a4, primary text #b65f3b, accent #ff9f68, secondary #ff784f, and standard black shadow.
    - All main screens and reusable UI components now reference theme colors and fonts for a consistent, inviting look.
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

### [DONE] Quote Sharing (2025-04-30)
- Users can share a generated PNG image of the quote card via the native iOS share sheet.
- Only image-related activities are enabled for sharing.
- Watermark logic is enforced for non-premium users (only in shared image).
- Share sheet reliably presents after state-reset fix.
- Known limitation: Share sheet preview size is system-controlled and cannot be made larger.

---

### [DONE] Robust Quote Sharing & UI Polish (2025-05-01)
- Share sheet is now reliably presented on first tap using Identifiable `.sheet(item:)`.
- Unique file naming for each share prevents iOS caching issues.
- Background color `#ffeedf` is now consistently applied to quote card and quote list.
- Watermark logic and image-specific share options remain enforced.

---

### [DONE] UI/UX & Sharing Pipeline Improvements (2025-05-06)
- All quote sharing now uses the current theme's solid color background (no gradients), ensuring visual consistency between app and shared image.
- Debug/test preview UI has been removed from production.
- Share/like buttons are never included in the shared image.
- Share sheet shares UIImage directly, restoring all photo actions ("Save Image" etc.).
- SwiftUI overlays and sheets are now always applied to concrete views, improving stability.
- Theme system refactored: all backgrounds are solid Color for a unified rendering pipeline.

---

## Step 7: Widget Development — 
**Objective:** Deliver quotes directly to users’ lock screen/standby.
- [`WidgetEntry.swift`](../Widget/WidgetEntry.swift): Defines `QuoteWidgetEntry` and `QuoteWidgetProvider` for the widget’s timeline, loads the daily quote and theme from App Group UserDefaults (`group.com.wholeapp.shared`), and provides fallback logic if no quote is set.
- [`QuoteListView.swift`](../Features/Quotes/QuoteListView.swift): On every swipe or launch, saves the currently displayed quote to App Group UserDefaults for widget consumption, ensuring widget and app remain in sync.
- [`WidgetSettingsView.swift`](../Features/Settings/WidgetSettingsView.swift): Provides user-facing settings/help for the widget (MVP: displays most recent quote, no category selection yet).
- Widget timeline updates once per day for fresh content.
- Widget loads and applies the selected theme from shared storage.
- All technical details and code comments are up to date for maintainability and future extensibility.
**Outcome:** Widget and app remain in sync, the widget always displays the most recently shown quote, and the integration is robust for MVP.

---

## Step 8: Onboarding Flow and Data Sync — 
**Objective:** Guide new users through onboarding and save their data to Supabase.
- [`OnboardingView.swift`](../Features/Onboarding/OnboardingView.swift) and [`OnboardingViewModel.swift`](../Features/Onboarding/OnboardingViewModel.swift) implement a multi-step onboarding process, including notification preferences and premium intro.
- User profile and preferences are now saved using dedicated insert methods (`insertUserProfile`, `insertUserPreferences`) for new users.
- Robust error handling ensures onboarding only completes if both inserts succeed.
- All onboarding data is stored in the `users` and `userpreferences` tables, following the backend schema.

**Outcome:** Onboarding is robust, modular, and seamlessly syncs new user data to Supabase.

---

## Step 9: Paywall & Subscription Logic — 
**Objective:** Monetize via subscriptions and manage access.
- Implemented `PaywallView.swift` for subscription options/free trial.
- Developed `PaywallViewModel.swift` for StoreKit integration and subscription logic (stubs in place, ready for StoreKit 2).
- Premium gating for all features (unlimited swipes, theme/font customization, watermark-free images) is enforced using `UserProfile.subscriptionStatus` and `trialEndDate`.
- Paywall modal is triggered for free users at the swipe limit or when accessing premium features.
- All logic is model-driven, robust against backend changes, and clearly documented in the codebase.

- [x] StoreKit 2 integration for subscriptions and paywall logic (2025-04-24)
- [x] Apple-native restore logic and error handling (2025-04-24)

**Outcome:** Functional paywall using StoreKit 2 (StoreKitManager functionality integrated into `PaywallViewModel.swift`), users can subscribe and restore purchases. Subscription status sync with backend is a TODO in `PaywallViewModel.swift`.

---

## Step 10: Favorites Feature — 
**Objective:** Enable saving and revisiting favorite quotes.
- Built `FavoritesView.swift` to display saved quotes.
- Created `FavoritesViewModel.swift` for managing favorites (persisted via Supabase `LikedQuotes` table).
- Integrated Favorites as a dedicated tab in the main TabView navigation.
- All logic is robust, model-driven, and clearly commented.

**Outcome:** Users can favorite/unfavorite quotes and view them in `FavoritesView.swift` (managed by `FavoritesViewModel.swift`). Changes are synced via `SupabaseService`. Real-time sync capability depends on `SupabaseService`'s implementation of real-time listeners.

---

## Step 11: User-Generated Quotes (Premium) — 
**Objective:** Let premium users create and submit their own quotes.
- Implemented `UserQuoteEditorView.swift` with a modern, minimal UI for submitting bilingual quotes.
- The editor uses soft backgrounds, pastel chips, and robust validation for a delightful UX.
- Quotes are saved to the `userquotes` table in Supabase.
- Moderation/approval logic is planned for future versions.
**Outcome:** Premium users can now contribute original quotes, increasing engagement and value.

---

## Step 12: Notifications & Analytics — 
**Objective:** Enhance engagement and gather usage insights.
- Refactored notification settings logic to use the `UserPreferences` model exclusively, eliminating legacy references from `UserProfile`.
- Updated `UserPreferences` struct: `selectedCategories`, `notificationTime`, and `notificationsEnabled` are now mutable (`var`) to support real-time UI changes and syncing.
- Updated `NotificationSettingsView.swift` and related UI to bind directly to `userProfile.userPreferences`, enabling robust, two-way data flow.
- Added a static `mock` property to `UserProfileViewModel` for improved SwiftUI previews and testing.
- Removed duplicate `LikedQuote` struct from `SupabaseService.swift` to ensure a single source of truth for liked quotes, preventing redeclaration errors.
- All notification preference logic, scheduling, and Supabase syncs are now model-driven and robustly commented.
- Analytics is deferred; `AnalyticsService.swift` is a placeholder for now and will be implemented post-MVP.
**Outcome:** Users can reliably enable, disable, and schedule daily notifications; preferences are seamlessly managed and synced with the backend. Codebase is maintainable and aligned with backend schema.

---

## Step 13: Theming & Styling — 
**Objective:** Ensure a cohesive, attractive design.
- Used `Theme.swift` and `ThemeManager.swift` for all colors, fonts, and appearance.
- Applied the new warm "leah valencia" palette as default, and ensured all screens/components use semantic theme colors and fonts.
**Outcome:** The app has a consistent, appealing look that matches the latest design direction.

---

## Step 14: Testing & Quality Assurance — 
**Objective:** Ensure reliability and catch bugs before release.
- Write unit tests for critical models/services (e.g., `QuoteViewModel.swift`, `AuthService.swift`).
- Create UI tests for key flows (onboarding, paywall, quote browsing).
**Outcome:** The app is stable and ready for App Store submission.

---

## Step 15: Final Review & Launch — 
**Objective:** Prepare for App Store submission and launch.
- Review all features, polish UI, and fix outstanding bugs.
- Prepare App Store assets, descriptions, and screenshots.
- Submit for review and monitor analytics post-launch.
**Outcome:** Whole is available for users, with a plan for post-launch improvements.

---

### Progress & Next Steps (as of 2025-04-22)

- All foundational steps through settings are .
- **Step 6: Sharing, Theming, and Paywall Polish** is now .
- **Step 7: Widget Development** is now .
- **Step 8: Onboarding Flow and Data Sync** is now .
- **Step 9: Paywall & Subscription Logic** is now .
- **Step 10: Favorites Feature** is now .
- **Step 11: User-Generated Quotes (Premium)** is now .
- **Step 12: Notifications & Analytics** is now .
- **Step 13: Theming & Styling** is now .
- **Step 14: Testing & Quality Assurance** is next.
- **Step 15: Final Review & Launch** will follow testing.

---

> For detailed guidance on each step, refer to the respective documentation files in `/docs`.

### 2025-04-22: Universal UUID Migration
- All identifiers (userId, quoteId, etc.) across models, view models, and services now use `UUID` for type safety and backend consistency.
- All SupabaseService methods and all usages updated to expect and use `UUID` for IDs.
- Hardcoded sample quotes and widget demo data now use `UUID()` for IDs.
- Codebase is now free of String/UUID conversion errors and is type-safe throughout.

### 2025-04-22: SwiftUI Performance Optimization
- Refactored `QuoteListView` to extract the main TabView and break up complex expressions, resolving compiler errors and improving maintainability.
- Ensured overlays/popups remain modular and commented for future extensibility.

### 2025-04-29: Quote List UI Polish
- Quote List: Removed horizontal scroll indicator, set background to #ffeedf, and standardized shadow on all floating buttons.

### Next Steps
- Continue to monitor for any lingering type mismatches or legacy String IDs.
- Ensure all documentation remains up-to-date with model and service changes.
