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
- [Planned] Sharing and paywall features.

---

## MVP Feature Summary (2025-04-22)
- Horizontal quote browsing (carousel style), 10/day for free users.
- Like = Save, with native feedback.
- Share via native iOS share sheet.
- Widget integration: displays the last quote seen in the app (saved on swipe or launch).
- Popups for like/limit reached.
- Paywall CTA and theme switch on main UI.
- Serene Minimalism default theme.

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