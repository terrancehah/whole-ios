# Tech Stack for Whole

## Frontend
- **iOS App**: SwiftUI (for building the main interface and views)
- **Widget**: WidgetKit (for lock screen and standby mode widgets)
- **Onboarding:** SwiftUI, Combine, and Supabase. Category selection uses the `QuoteCategory` enum and preferences are saved with the `UserPreferences` model.
  - User profile and preferences are saved to Supabase using dedicated insert methods (`insertUserProfile`, `insertUserPreferences`) during onboarding.
  - Notification permission is requested only if enabled by the user.
  - Error handling ensures onboarding only completes if both inserts succeed.
- **Favorites (Liked Quotes):**
  - Implemented with SwiftUI, Combine, and Supabase real-time backend sync.
  - Uses a dedicated `LikedQuotes` table in Supabase for persistence and cross-device access.
- **User-Generated Quotes:**
  - Implemented with SwiftUI and Combine for a modern, reactive editor UI.
  - Supabase is used for backend storage and future moderation flows.
- SwiftUI performance best practices implemented: Large views (e.g., quote carousels) now use extracted subviews and computed properties to avoid compiler errors and improve maintainability.
- Example: `QuoteListView` refactor (2025-04-22).
- Supabase `users.email` is nullable, unique, and may be NULL for anonymous users.
- Quotes `categories` is a Postgres text[] array, not a JSON string; CSV import uses array syntax.
- UI: All buttons use a corner radius of 12 and have consistent shadows; QuoteListView fills the screen; Chinese text uses a lighter color.
- Error popups for backend issues are now suppressed unless relevant.
- **Image Generation and Sharing:**
  - SwiftUI for UI components and quote card rendering.
  - UIKit (UIHostingController, UIActivityViewController) for converting SwiftUI views to images and presenting the native iOS share sheet.
  - Image generation pipeline includes forced layout and white background for reliable rendering.
- **SwiftUI + UIKit Integration:** Quote sharing pipeline uses SwiftUI for view rendering and UIKit for image generation and sharing, ensuring robust and native user experience.
- **Theme System:** All backgrounds are solid Color (no gradients), simplifying rendering and ensuring consistency between app UI and share images.
- Identifiable-driven `.sheet(item:)` for robust sheet presentation.
- Unique file naming (UUID) for image sharing.
- Consistent background color handling for quote UI.

## Backend
- **Platform**: Supabase
  - **Authentication**: Handles user sign-up, login, and security
  - **Database**: PostgreSQL (for storing quotes, user data, and preferences)
  - **Real-time Updates**: Supports future features like live quote sharing
  - All identifiers in the app and backend (Supabase) are now UUIDs for type safety and consistency.
  - SupabaseService API updated to require UUID for all IDs.

## Analytics
- **Tool**: Firebase Analytics (for tracking user behavior and engagement)

## Other Frameworks
- **Notifications**: UserNotifications (for daily quote notifications)
- **In-App Purchases**: StoreKit 2 (async/await, robust error handling, Apple-native restore flow)

---

## Key Technologies (Updated)
- SwiftUI: UI, navigation, and theming.
- Combine: State management, async data.
- Supabase: Backend, auth, quote storage, like/save sync.
- Native iOS share sheet: Sharing quotes.
- Planned: Local caching for offline quotes.

---