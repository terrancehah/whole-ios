# Whole

**Whole** is an MVP (Minimum Viable Product) iOS application designed to deliver bilingual (English and Chinese) quotes to your lock screen and standby mode, providing daily inspiration and motivation. This project is intentionally scoped for rapid development—ideally to be completed within 1–2 weeks. The codebase and documentation emphasize clarity, maintainability, and a focus on core features for fast iteration and validation.

---

## Features
- Browse bilingual quotes with horizontal swipe.
- Like and unlike quotes, with real-time sync to Supabase backend.
- Robust error handling for all quote interactions.
- Quote card and sharing support user-selectable themes (Serene Minimalism, Elegant Monochrome, Soft Pastel Elegance).
- All other UI follows system light/dark mode for maximum consistency with iOS.
- Theme selection UI in CustomizationView; theme state managed globally via ThemeManager.
- Widget displays the quote most recently shown in the app, always keeping widget and app in sync.
- **Anonymous Account Support:** On first launch, the app creates a backend account with a NULL email for every user. All features (including backend sync) work before explicit login. Data is migrated to the real account when the user signs up.
- All onboarding data is always tied to the authenticated backend account (anonymous or real), ensuring seamless migration and robust backend sync.
- [Planned] Sharing and paywall features.
- Robust quote sharing: Share sheet always appears on first tap, with unique file naming and image-specific options. Watermark logic enforced for non-premium users.
- Consistent UI: Background color `#ffeedf` for quote card and list, reflected in both UI and shared images.

---

## MVP Feature Summary (2025-04-22)
- Horizontal quote browsing (carousel style), 10/day for free users.
- Like = Save, with native feedback.
- Share via native iOS share sheet.
- Widget integration: displays the last quote seen in the app (saved on swipe or launch).
- Popups for like/limit reached.
- Paywall CTA and theme switch on main UI.
- Serene Minimalism default theme.
- **Anonymous Account Support:** On first launch, the app creates a backend account with a NULL email for every user. All features (including backend sync) work before explicit login. Data is migrated to the real account when the user signs up.
- All onboarding data is always tied to the authenticated backend account (anonymous or real), ensuring seamless migration and robust backend sync.

---

## Project Roadmap (Summary)
- **Step 1:** Data Models & ViewModels — Core models for users, quotes, and subscriptions. *(Complete)*
- **Step 2:** Backend Integration — Supabase for real-time data, authentication, and quote management. *(Complete)*
- **Step 3:** Reusable UI Components — Modular quote cards, theming, and previews. *(Complete)*
- **Step 4:** Main Quote Browsing Interface — Swipeable quote list with premium gating and error handling. *(Complete)*
- **Step 5:** Complete Settings Sections — Full-featured settings, including profile, theme, subscription, widget, and notification preferences. *(Complete)*
- **Step 6:** Sharing, Theming, and Paywall Polish — Share sheet, premium gating, watermark logic, and UI polish. *(Complete)*
- **Step 7:** Widget Development — WidgetKit integration, always displays the last quote seen in the app, robust sync and theming. *(Complete)*
- **Step 8:** Onboarding Flow and Data Sync — Multi-step onboarding (welcome, widget, preferences, notification, subscription), robust error handling, and Supabase insert logic. *(Complete)*
- **Step 9:** Paywall & Subscription Logic — StoreKit integration, premium gating, and robust paywall logic. *(Complete)*
- **Step 10:** Favorites Feature — Save and revisit liked quotes, synced with Supabase. *(Complete)*
- **Step 11:** User-Generated Quotes (Premium) — Premium users can create and submit their own quotes via a modern editor. *(Complete)*
- **Step 12:** Notifications & Analytics — Notification logic refactored for robust syncing; analytics service stubbed for post-MVP. *(Complete)*
- **Step 13:** Theming & Styling — Cohesive design, semantic theme colors, and consistent appearance. *(Complete)*
- **Step 14:** Testing & Quality Assurance — Unit/UI tests for reliability (Todo).
- **Step 15:** Final Review & Launch — App Store submission and launch (Todo).
- **Ongoing/Future:** Advanced widget customization, additional sharing, and feature expansion based on user feedback. *(Planned)*

---

## Recent Changes
- **Universal UUID Migration:** All identifiers in models, view models, services, and widgets are now UUIDs. All SupabaseService methods and usages updated accordingly. All sample/mock data now uses UUID().
- **SwiftUI Performance Refactor:** `QuoteListView` was refactored to extract the TabView and overlays into computed properties, resolving SwiftUI type-checking errors and improving maintainability.
- **Onboarding Completion Persistence:** Onboarding completion is now tracked persistently using @AppStorage. Users only see onboarding on first launch, as per app-flow.md.
- **Anonymous Account Support:** On first launch, the app creates a backend account with a NULL email for every user. All features (including backend sync) work before explicit login. Data is migrated to the real account when the user signs up.
- Quotes table `categories` is now a Postgres text[] array, not a JSON string. The CSV import uses Postgres array syntax for compatibility.
- UI: QuoteListView fills the screen, all buttons use a corner radius of 12 and have consistent shadows, Chinese text uses a lighter palette color.
- Error popups for backend issues are now suppressed unless relevant.

---

## Changelog
- Refactored onboarding flow to a multi-step experience:
  - Preferences split into categories, name, and goals, each with their own screen.
  - Categories and goals now use a grid selection UI with colored borders.
  - Back and skip buttons added for better navigation.
  - Notification permission is now triggered directly by the toggle.
  - Widget install prompt moved after preferences and notifications.
  - Trial screen improved with a reminder toggle, clear description, and skip option.
  - Theme color now applies to the entire onboarding background.

- Updated documentation to reflect the new onboarding logic and UI/UX.

- **Universal UUID Migration:** All identifiers in models, view models, services, and widgets are now UUIDs. All SupabaseService methods and usages updated accordingly. All sample/mock data now uses UUID().
- **SwiftUI Performance Refactor:** `QuoteListView` was refactored to extract the TabView and overlays into computed properties, resolving SwiftUI type-checking errors and improving maintainability.
- **Onboarding Completion Persistence:** Onboarding completion is now tracked persistently using @AppStorage. Users only see onboarding on first launch, as per app-flow.md.
- **Anonymous Account Support:** On first launch, the app creates a backend account with a NULL email for every user. All features (including backend sync) work before explicit login. Data is migrated to the real account when the user signs up.
- Quotes table `categories` is now a Postgres text[] array, not a JSON string. The CSV import uses Postgres array syntax for compatibility.
- UI: QuoteListView fills the screen, all buttons use a corner radius of 12 and have consistent shadows, Chinese text uses a lighter palette color.
- Error popups for backend issues are now suppressed unless relevant.

### 2025-05-06: Sharing & UI Consistency Update
- Quote sharing now uses a solid color background matching the current theme (no gradients).
- Shared images never include UI controls; watermark logic is enforced for non-premium users.
- Share sheet shares UIImage directly, restoring all photo actions.
- Debug/test preview UI has been removed from production.
- All overlays, sheets, and backgrounds follow SwiftUI best practices.

---

## Features (2025-04-30)
- Share quotes as images: Users can share a PNG image of the quote card via the native iOS share sheet. Only image-related options are shown. Watermark is present for non-premium users in the shared image only.
- Share sheet reliably appears on every tap after UI state fix.

---

## Features (2025-05-01)
- Robust quote sharing: Share sheet always appears on first tap, with unique file naming and image-specific options. Watermark logic enforced for non-premium users.
- Consistent UI: Background color `#ffeedf` for quote card and list, reflected in both UI and shared images.

---

## Data Model
- All IDs (`userId`, `quoteId`, etc.) are UUIDs throughout the codebase and database schema.

---

## Premium Gating and Paywall Implementation
- **Premium gating and paywall logic are now fully implemented and documented.**
  - Unlimited quote swipes, theme/font customization, and watermark-free sharing are enforced using the user's subscription status and trial end date.
  - Gating is handled in `QuoteListView.swift`, `CustomizationView.swift`, and `QuoteImageGenerator.swift`.
  - All gating logic is clearly commented for maintainability.

---

## Setup

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/terrancehah/Whole.git
   ```

2. **Open the Project in Xcode**:
   ```bash
   open Whole.xcodeproj
   ```

3. **Install Dependencies**:
   - Use Swift Package Manager or CocoaPods (if applicable) to install required packages.

4. **Configure Supabase**:
   - Create a Supabase project and obtain your API keys.
   - Update the app's configuration with your Supabase API keys.

5. **Run the App**:
   - Launch the app on a simulator or physical device via Xcode.

---

## Development

### Frontend:
- Use SwiftUI for building user interfaces.
- Follow the guidelines outlined in `frontend-guidelines.md` for consistent design.

### Backend
- All quote and like/unlike operations are performed via SupabaseService.
- Requires `liked_quotes` table with `userId` and `quoteId` fields in Supabase.
- Use Supabase's Swift client for all backend interactions (authentication, database, etc.).

### Architecture
- Quote card and sharing support user-selectable themes (Serene Minimalism, Elegant Monochrome, Soft Pastel Elegance).
- All other UI follows system light/dark mode for maximum consistency with iOS.
- Theme selection UI in CustomizationView; theme state managed globally via ThemeManager.

---

## Contributing
Please read the contribution guidelines before submitting pull requests.