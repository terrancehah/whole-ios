## Quotes Filtering by User Preferences (2025-05-08 Update)

- Quotes are now always filtered server-side by the user's selected categories, which are compulsory during onboarding.
- The filtering is performed by passing `selectedCategories` from `UserPreferences` to the backend query.
- The `QuoteViewModel.fetchQuotes(selectedCategories:)` method must be called with the user's current selected categories. This is typically done on view appearance:
  ```swift
  viewModel.fetchQuotes(selectedCategories: userProfile.userPreferences.selectedCategories)
  ```
- Quotes are now fetched on both `.onAppear` and `.onChange` for user preferences.
- Errors are surfaced in the UI for debugging.
- The no-quotes prompt has been removed for a cleaner UI.

### Technical Implementation
- `SupabaseService.fetchQuotes(categories:)` performs the server-side filter using `.in("category", ...)`.
- `QuoteViewModel` no longer tries to read categories from `UserProfile`, but expects them to be passed in as a parameter.
- `QuoteListView` is responsible for providing the correct categories to the view model on `.onAppear` and `.onChange` of `userProfile.userPreferences.selectedCategories`.

### Example Usage
```swift
// In QuoteListView.swift
dispatchQueue.main.async {
    viewModel.fetchQuotes(selectedCategories: userProfile.userPreferences.selectedCategories)
}
```

### QuoteViewModel Lifecycle and User Context (2025-05-08 Update)

To ensure a stable and consistent display of quotes and user-specific data (like liked quotes), the `QuoteViewModel`'s lifecycle and user context are managed as follows:

- **Lifecycle Management**: `QuoteViewModel` is instantiated as a `@StateObject` within `RootAppView`. This ensures that a single, persistent instance of `QuoteViewModel` is maintained for the primary quote display throughout the relevant part of the app's lifecycle, preventing issues caused by premature deallocation or multiple conflicting instances.
- **Dependency Injection**: This `@StateObject`-managed instance of `QuoteViewModel` is then passed down as a dependency to `QuoteListView`.
- **User Context Synchronization**:
    - When `RootAppView` confirms that the user authentication state is ready (via `isAuthReady`) and `UserProfileViewModel` has synced the current user's profile, `RootAppView` updates the `user` property of the shared `QuoteViewModel` instance.
    - `QuoteViewModel` has a `didSet` observer on its `user` property. When this property is updated with a new user, this observer automatically triggers a call to `fetchLikedQuotes()` to load the liked quotes specific to that user.
- **Quote Fetching**: The responsibility for initiating the primary quote fetch (based on categories) still resides with `QuoteListView` (e.g., in `.onAppear` or when categories change), which calls `fetchQuotes(selectedCategories:)` on its `QuoteViewModel` instance.

---

**This reflects the latest architecture and code logic as of 2025-05-08.**

## App Flow for Whole

## 1. Launch and Onboarding
- **Launch Screen**
  - Purpose: Welcomes users and establishes branding.
  - Details:
    - Displays the app logo or branding for a few seconds before transitioning to onboarding.

### Initial Authentication & Session Handling
- Upon app launch, before displaying content that depends on user identity (like onboarding or the main app view), an initial authentication check occurs in `RootAppView`'s `.task` modifier:
  1.  **Session Check**: The app inspects `AuthService` (which wraps the Supabase client) to determine if an existing user session is available. This includes previously established anonymous sessions that Supabase client persists locally.
      - `AuthService.shared.session` and `AuthService.shared.user` are consulted.
      - `AuthService` itself subscribes to Supabase's `onAuthStateChange` to keep its `session` and `user` properties synchronized with the authentication state.
  2.  **Existing Session Found**:
      - If a valid session is found, the app proceeds using this established user identity.
      - `RootAppView.isAuthReady` is set to `true`.
  3.  **No Existing Session Found**:
      - The app attempts to sign in a new anonymous user by calling `AuthService.shared.signInSupabaseAnonymous()`.
      - If successful, Supabase creates a new anonymous user session. This new user's ID becomes available via `AuthService.shared.user.id` (once `AuthService` updates its properties).
      - `RootAppView.isAuthReady` is set to `true`.
      - If `signInSupabaseAnonymous()` fails, an error is logged, and `isAuthReady` may be set to `false` or an appropriate error state handled in the UI.
  4.  **User Preferences Fetching**:
      - Once `RootAppView.isAuthReady` transitions to `true`, the app triggers fetching of user preferences:
        ```swift
        // In RootAppView, triggered by .onChange(of: isAuthReady)
        userProfileViewModel.fetchUserPreferences(userId: userProfileViewModel.user.id)
        ```
      - This ensures preferences are loaded for the correct user ID, whether it's from a restored session or a newly created anonymous one.
      - The `userProfileViewModel.user` property is expected to be synchronized with `AuthService.shared.user` to reflect the currently authenticated user.

- **Onboarding Screens**
  - Objective: Introduce the app and collect user preferences to personalize the experience.
  - **Account Creation:**
    - If the user does not have an account, onboarding will automatically create a Supabase Auth account using Supabase's built-in anonymous sign-in mechanism at the end of onboarding.
    - The session and refresh tokens are stored securely in the Keychain for seamless auto-login on future launches.
    - All onboarding data is always tied to this backend account, supporting seamless upgrade and backend sync.
  - Screens:
    1. **Welcome Screen**
       - Brief intro to the app.
       - Only a continue button is shown.
    2. **Preferred Categories**
       - User selects their preferred quote categories using a grid layout.
       - Each category displays as a selectable card with a colored border when selected.
       - Continue button is enabled only when at least one category is selected.
       - Skip button at top right allows proceeding without selection.
    3. **Name**
       - User can enter their name (optional).
       - Skip button at top right.
    4. **Goals**
       - User selects personal goals in a grid layout (same UX as categories).
       - Continue button enabled only when at least one goal is selected.
       - Skip button at top right.
    5. **Notification Preferences**
       - User can enable daily quote notifications with a toggle.
       - When enabled, the system notification permission prompt appears immediately.
       - User can set notification time if enabled.
       - Continue button to proceed.
    6. **Widget Installation**
       - User is prompted to install the widget after preferences and notifications.
       - "Install Widget" and "Later" buttons.
    7. **Trial / Subscription**
       - Clear trial description and reminder toggle.
       - "Start Free Trial" and "Skip Trial" buttons.
    8. **Completion**
       - Onboarding is marked as complete and user proceeds to the main app.

- **Navigation:**
  - Back button is present on all steps except the first.
  - Skip button is at the top right for all skippable steps.

- **Theme:**
  - Theme color now applies to the entire onboarding screen background.

- **Persistence:**
  - Onboarding completion is tracked with a persistent flag, so returning users skip onboarding.

- **Onboarding Data Saving**
  - User profile and preferences are saved to Supabase using `insertUserProfile` and `insertUserPreferences` for new users. All IDs are passed as `UUID`.
  - If the user is not authenticated, onboarding will first create a Supabase Auth anonymous account using the built-in anonymous sign-in (no fake email/password is generated).
  - Robust error handling ensures onboarding only completes if both inserts succeed.
  - All onboarding data is stored in the `users` and `userpreferences` tables, following the backend schema and using UUIDs for all identifiers.

- **Onboarding Data Binding:**
  - All onboarding steps (category selection, name, goals, notification preferences, etc.) now save data directly to the backend using the currently authenticated user's UUID (from Supabase Auth). For anonymous users, the email may be nil.
  - This ensures all onboarding data is always tied to the correct backend account (anonymous or real), supporting seamless upgrade and backend sync.

- **Paywall Screen (Updated 2025-06-23)**
  - **Purpose**: To present a clean, professional, and informative interface that clearly communicates the value of a premium subscription.
  - **Design**: The paywall features a modern, single-column layout with a prominent title, two distinct info cards (for benefits and the trial timeline), and a vibrant call-to-action button. The design uses a cohesive color palette and clear typography to create an inviting and trustworthy user experience. For detailed design specifications, see `docs/frontend-guidelines.md`.
      - Close Button: Access free version with limitations.

## Anonymous User Provisioning and Backend Account Creation
- **Anonymous User Provisioning:**
  - On first launch, the app generates a Supabase Auth anonymous account **as part of onboarding**.
  - The session and refresh tokens are stored securely in the Keychain for silent login on future launches.
  - All user data (preferences, favorites, premium state) is linked to this backend account from the start, even before explicit login.
  - When the user later logs in with Google, Apple, or email, all data is migrated from the anonymous account to the new authenticated account.
- **Anonymous User Email Handling:** Anonymous users now have their email set to `NULL` in the database, not an empty string or placeholder. This prevents unique constraint issues and aligns with the Supabase schema.

## Subscription & Paywall Logic (Updated 2025-06-23)
- **UI Overhaul**: The paywall UI has been significantly redesigned to improve clarity, aesthetics, and user trust. It now features a card-based layout that clearly outlines premium benefits and the trial timeline.
- **StoreKit 2**: The underlying logic continues to use StoreKit 2 for all subscription and paywall flows.
- **Functionality**: The paywall allows users to start a 7-day free trial or restore purchases.
- Subscription restoration uses StoreKit 2's recommended approach:
    - All verified transactions are collected using `for try await`.
    - Only non-revoked, correct-product transactions are considered.
    - The latest transaction's `purchaseDate` is used as the start date, and `renewalDate` from `renewalInfo` as the end date.
- All error handling is robust and follows Swift concurrency best practices.
- All subscription and trial state changes are ready to be synced with Supabase backend.

## 2. Main Interface
- **Quote Cards**
  - Display: Single quote per card with English text on top, Chinese translation below.
  - Interaction: Swipe left or right to view new quotes.
  - Buttons:
    - Like: Saves quote to Favorites tab.
    - Share: Generates shareable image (watermarked for free users).
  - Free User Limit: 10 quotes/day with subscription prompt.
  - **Quote Categories Storage:** The `category` field in the `quotes` table is now a Postgres `text` column, not a `text[]` array. The Swift model expects a single `String` and the backend returns a single value, ensuring seamless decoding.
  - **CSV Import:** When importing quotes, the `category` column must use a single string value (e.g., `"Inspiration"`) for compatibility with the new type.

- **Navigation Elements**
  - Top Navigation Bar:
    - Categories Button: Filter quotes by selected categories.
    - Settings Button: Access Settings tab.
    - Customize Button: Theme and font options (premium feature).
  - Tab Bar (Bottom):
    - Quotes: Default tab with swipeable cards.
    - Favorites: Saved quotes collection.
    - Settings: Customization and account options.

## 3. Quote Browsing Flow (Updated)
- **Main Interface:**
  - Horizontal swipe (carousel style) for browsing quotes.
  - Users can scroll both forward and backward; quotes are not dismissed.
  - Free users: Limited to 10 quotes per day (loaded all at once).
  - Offline access: Previously loaded quotes are viewable offline (caching planned).
- **Like Action:**
  - Tapping Like fills the heart icon and saves the quote to the user's collection.
  - Native-style bottom popup confirms the action ("Liked!").
  - Like status syncs with Supabase immediately.
- **Share Action:**
  - Opens native iOS share sheet, with a preview image of the quote.
- **Swipe Limit:**
  - Upon reaching daily limit, a native-style bottom popup appears.
  - Paywall CTA button highlights/appears after limit is hit.
- **Theme & Settings:**
  - Theme switcher and settings buttons on main interface.
  - Default theme: Serene Minimalism with a warm palette (#ffeedf, #ffd1a4, #b65f3b, #ff9f68, #ff784f).
- **Error Handling:**
  - Native-style retry button for load failures.
  - **Error Handling:** Error popups for backend issues (such as liked_quotes table) are now suppressed unless relevant to the user.
  - **Robust Error Handling:** Robust error handling ensures onboarding and data sync only complete if all backend operations succeed.

## 4. Settings Screen
- **Quote Categories**
  - Edit or update preferred categories.
  - Mirrors onboarding selections.

- **Customization**
  - App background options.
  - Theme selection (light/dark mode) with semantic theme colors and fonts for backgrounds, cards, buttons, and text.
  - Font style choices.
  - Premium features locked for free users.
  - **UI Improvements:**
    - `QuoteListView` now fills the entire screen for a modern look.
    - All `CustomButton` instances have a corner radius of `12` and a consistent shadow for visual polish.
    - Chinese quote text uses a lighter palette color for improved readability.

- **Subscription Management**
  - View current status.
  - Upgrade/downgrade options.
  - Cancel subscription functionality.

- **Widget Configuration**
  - Set widget preferences (size only; no category selection for MVP).

- **Notifications**
  - Daily quote timing adjustment.
  - Default set to 8 AM.

## 5. Widget
- **Lock Screen and Standby Mode**
  - Display: One bilingual quote, updated daily (random from all quotes).
  - Interaction: Tap to open specific quote in app.
  - Design: Simple, clean layout for glanceable reading.

## 6. Notifications
- **Daily Quote Notification**
  - Timing: User-defined (default: 8 AM).
  - Content: Bilingual quote text.
  - Deep Link: Opens app to specific quote.
  - Settings: Configurable in Settings tab.

## 7. Sharing
- **Generate Quote Image**
  - Access: Available from Quotes or Favorites tab.
  - Free Users: Images include "Whole" watermark.
  - Premium Users: Watermark-free images.
  - Share Options: Compatible with installed social media apps.
  - Platforms: Instagram, Instagram Stories, WhatsApp, WeChat, etc.

## 7. Favorites Tab Flow (2025-06-20)

- **Viewing Favorites**: Users can navigate to the "Favorites" tab to view a list of all the quotes they have previously liked. The list is presented as a series of vertically scrolling cards. For detailed visual and layout specifications, see the "Favorites Tab" section in `frontend-guidelines.md`.

- **Deleting Favorites**: There are two methods for removing quotes from the favorites list:
  1.  **Swipe to Delete**: Users can perform a standard leading-to-trailing swipe gesture on any quote card to reveal a "Delete" button. Tapping this button removes the quote from their favorites.
  2.  **Edit Mode**: An "Edit" button is located in the navigation bar. Tapping this button puts the list into an edit mode, allowing the user to select multiple quotes and delete them in a single action. Tapping "Done" (which replaces "Edit") exits this mode. This provides a clear and discoverable alternative to the swipe gesture.

- **States**:
  - **Loading State**: A progress indicator is shown while the list of favorited quotes is being fetched from the backend.
  - **Empty State**: If the user has not liked any quotes, a view with a heart icon and instructional text is displayed.

## 8. AuthService
- **Password Reset:**
  - The AuthService provides a method to send password reset emails via Supabase.
  - Usage: Call `resetPassword(email:completion:)` with the user's email address.

## Authentication Service Singleton Pattern (2025-04-27)

- The AuthService class now uses the singleton pattern via `static let shared = AuthService()`.
- All authentication and user state is accessed via `AuthService.shared`.
- The initializer is now private to enforce singleton usage.
- All onboarding and authentication logic must reference `AuthService.shared` instead of creating new instances.

### Example Usage
```swift
// Access the current user
let user = AuthService.shared.user

// Sign in anonymously
let signedInUser = try await AuthService.shared.signInSupabaseAnonymous()
```

## Widget Integration Progress (2025-04-18)
- The widget now displays the quote most recently shown on the main interface.
- When the user swipes to a new quote or launches the app, the currently displayed quote is saved to App Group UserDefaults for widget access.
- This ensures the widget and app are always in sync, providing a seamless user experience.
- Ref: Logic implemented in `QuoteListView.swift` using `saveQuoteForWidget(_:)` from `QuoteViewModel`.

## Technical Implementation Notes
- The widget reads the saved quote from App Group UserDefaults (key: `widgetDailyQuote`).
- If no quote is available, the widget falls back to a static demo quote.
- All code is clearly commented for future maintainability.

---
### Analytics Tracking (Deferred for MVP)
- `AnalyticsService.swift` is a placeholder for now; analytics integration will be implemented after MVP launch.
- No analytics events are tracked in the current MVP build.

### Premium Feature Gating & Paywall Logic (2025-04-17)
- All premium gating logic is now fully implemented and clearly documented in the codebase.
- Only users with an active trial or paid subscription (see `UserProfile.subscriptionStatus` and `trialEndDate`) can access premium features:
  - Unlimited quote swipes (gated in `QuoteListView.swift`)
  - Theme and font customization (gated in `CustomizationView.swift`)
  - Watermark-free quote images (gated in `QuoteImageGenerator.swift`)
- Free users:
  - Are limited to 10 quotes/day
  - Can only use the default theme
  - See a lock icon and paywall prompt when attempting to access premium features
- All gating logic is model-driven, based on the actual user profile fields, and updates reactively.
- Paywall modal (`PaywallView`) is shown when a free user hits the swipe limit or tries to select a premium theme.
- Code comments have been added for maintainability and future onboarding.

### SwiftUI Performance Optimization (2025-04-22):
  - Refactored `QuoteListView.swift` to extract the main `TabView` into a private computed property (`quoteTabView`) and broke up complex expressions for `ForEach`.
  - This change resolves SwiftUI compiler type-checking errors in large views and improves maintainability.
  - All overlays and popups remain modular and clearly commented for future extensibility.
  - See the section on premium gating for details about where this refactor is applied.

### Favorites (Liked Quotes) Feature (2025-04-21)
- Users can now save and revisit favorite quotes ("Liked Quotes").
- Favorites are displayed in a dedicated tab (`FavoritesView`) in the main TabView navigation.
- All favorites are synced with Supabase in real-time using the new `LikedQuotes` table.
- The feature is managed by `FavoritesViewModel` and uses a robust, model-driven approach.
- Users can remove favorites with swipe actions; empty and error states are handled gracefully.
- The UI is minimal, modern, and clearly commented for maintainability.

### Onboarding Flow (COMPLETE)
The onboarding flow guides new users through a welcome, widget introduction, category selection, and preference collection. It is implemented in `OnboardingView.swift` and managed by `OnboardingViewModel.swift`, with all user preferences saved to Supabase using the new `UserPreferences` model. All category selection is type-safe using the `QuoteCategory` enum.

### Theme Management
- **Quote Theme (Card/Sharing Only):**
  - Users can select a visual style (Serene Minimalism, Elegant Monochrome, Soft Pastel Elegance) for quote cards and share images.
  - Managed by `ThemeManager` and set via `CustomizationView`.
  - Only affects `QuoteShareCardView` and sharing, NOT the rest of the app UI.
- **System-wide Theme:**
  - All other UI (navigation, settings, paywall, etc.) follows system light/dark mode using system colors.
  - No custom theme selection for global UI—respects iOS appearance settings.

### User Profile State & Sync (2025-04-17)
- `UserProfileViewModel` is owned by `SettingsView` and passed to all settings-related child views (e.g. `CustomizationView`).
- On appear, `SettingsView` calls `.refresh(userId:)` to sync the latest user profile and subscription state from Supabase.
- All premium gating and paywall logic in settings/customization flows now reactively update based on the latest profile state.
- `SupabaseService` provides `fetchUserProfile(userId:completion:)` for backend sync.
- This ensures robust, model-driven state management and a seamless upgrade/restore experience.

### Data Models: Quote

- **Swift Model:**
  - File: `Models/QuoteModel.swift`
  - Structure:
    - `id: UUID` (UUID)
    - `englishText: String`
    - `chineseText: String`
    - `category: QuoteCategory` (single category, not array)
    - `createdAt: Date?`
    - `createdBy: UUID?`
- **Maps to Supabase table:** `quotes`
- **Coding keys** ensure correct mapping between Swift and Supabase/JSON fields.

### Data Models: UserProfile
- **Swift Model:**
  - File: `Models/UserModel.swift`
  - Structure:
    - `id: UUID` (UUID)
    - `email: String?`
    - `name: String?`
    - `gender: String?`
    - `goals: [String]?`
    - `subscriptionStatus: String`
    - `trialEndDate: Date?`
    - `subscriptionStartDate: Date?`
    - `subscriptionEndDate: Date?`
    - `createdAt: Date?`
    - `updatedAt: Date?`
- **Maps to Supabase table:** `users`
- **Coding keys** ensure correct mapping between Swift and Supabase/JSON fields.

### Data Models: Subscription
- **Swift Model:**
  - File: `Models/SubscriptionModel.swift`
  - Structure:
    - `status: String`
    - `trialEndDate: Date?`
    - `startDate: Date?`
    - `endDate: Date?`
- **Maps to Supabase fields in `users` table**

### Data Models: UserQuote
- **Swift Model:**
  - File: `Models/UserQuoteModel.swift`
  - Structure:
    - `id: UUID` (UUID)
    - `userId: UUID`
    - `englishText: String`
    - `chineseText: String`
    - `createdAt: Date?`
- **Maps to Supabase table:** `userquotes`

### Data Models: LikedQuote
- **Swift Model:**
  - File: `Services/SupabaseService.swift`
  - Structure:
    - `id: UUID?`
    - `userId: UUID`
    - `quoteId: UUID`
- **Maps to Supabase table:** `liked_quotes`

### View Models
- **QuoteViewModel:**
  - File: `Features/Quotes/QuoteViewModel.swift`
  - Handles fetching, liking, and unliking quotes using Supabase integration.
  - Syncs liked quotes state with backend in real-time.
  - Provides robust error handling for all backend operations.

---
### Data Model Consistency
- All identifiers (userId, quoteId, etc.) are now consistently represented as `UUID` in all models, view models, and service methods.
- All Supabase interactions use `.uuidString` for IDs when required by the backend.
- All hardcoded sample quotes in code and widget logic now use `UUID()` for IDs to ensure type safety.

### Notification Preferences Flow (2025-04-21)
- Onboarding and Settings screens allow users to enable/disable daily quote notifications and set preferred delivery time.
- Preferences are stored in the `userpreferences` table (`notifications_enabled`, `notification_time`).
- All updates are synced to Supabase via `SupabaseService` partial update methods.
- `NotificationService` schedules/cancels notifications based on current preferences.
- Permission requests are handled natively and robustly in both onboarding and settings.
- All flows are clearly commented and tested for reliability.

### User-Generated Quotes (Premium) (2025-04-21)
- Premium users can create and submit their own bilingual quotes using an aesthetic, minimal editor (`UserQuoteEditorView`).
- The editor features soft backgrounds, clear input fields, pastel category chips, and robust validation.
- All submitted quotes are saved to the `userquotes` table in Supabase.
- Moderation/approval flow is planned for future releases.
- The UI and logic are fully commented and match the app's Serene Minimalism guidelines.

### Widget Demo Data
- The widget's demo/static quote now uses a `UUID()` for the quote ID, matching the rest of the codebase.

### Recent Refactoring
- All code, including previews, mocks, and tests, now uses `UUID` for all identifiers to ensure consistency and type safety across the app.
- All SupabaseService methods and all usages have been updated to expect and use `UUID` instead of `String` for IDs.

### [2025-04-29] Quote List UI/UX Improvements
- Removed the horizontal scroll indicator from the quote swipe view for a cleaner interface.
- Explicitly set the background color to #ffeedf for the quote list screen.
- Ensured all floating corner buttons (star, settings, etc.) have a consistent shadow effect for better visibility and depth.

See `QuoteListView.swift` for code details.

---

## Quote Sharing Flow (2025-05-06)
- Quote sharing uses a SwiftUI-to-UIKit pipeline to generate a PNG image of the quote card.
- The shared image uses the current theme's solid background color (no gradients), ensuring visual consistency.
- Share/like UI elements are never included in the shared image.
- The share sheet shares a UIImage directly, restoring all photo actions (e.g., "Save Image").
- The watermark is only present for non-premium users and only in the shared image, not in the main UI.
- The preview at the top of the share sheet is system-controlled and cannot be made larger by the app.
- Debug previews and test share buttons have been removed from production code.
- All overlays, sheets, and backgrounds are now applied to concrete views, not inside conditionals, following SwiftUI best practices.
- The image generation pipeline forces layout and uses the correct theme background color to prevent blank or mismatched images.

## [2025-05-06] Quote Sharing & UI Consistency
- Share sheet uses Identifiable-driven `.sheet(item:)` for robust, always-on-first-tap presentation.
- Each share action generates a unique PNG filename (UUID) to prevent iOS caching issues.
- The share sheet only appears after the image file is fully written and ready.
- Only image-related share options are shown; watermark logic enforced for non-premium users (watermark only in shared image).
- All backgrounds in the app are now solid colors (no gradients), ensuring a consistent rendering pipeline for both UI and sharing.
- Debug UI for image preview and test sharing has been removed for a clean user experience.