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

## MVP Feature Summary (2025-04-18)
- Horizontal quote browsing (carousel style), 10/day for free users.
- Like = Save, with native feedback.
- Share via native iOS share sheet.
- Widget integration: displays the last quote seen in the app (saved on swipe or launch).
- Popups for like/limit reached.
- Paywall CTA and theme switch on main UI.
- Serene Minimalism default theme.

---

## Project Roadmap (Summary)
- ✅ **Step 1:** Data Models & ViewModels — Core models for users, quotes, and subscriptions. *(Complete)*
- ✅ **Step 2:** Backend Integration — Supabase for real-time data, authentication, and quote management. *(Complete)*
- ✅ **Step 3:** Reusable UI Components — Modular quote cards, theming, and previews. *(Complete)*
- ✅ **Step 4:** Main Quote Browsing Interface — Swipeable quote list with premium gating and error handling. *(Complete)*
- ✅ **Step 5:** Settings & Customization — User profile, theme selection, and notification preferences. *(Complete)*
- ✅ **Step 6:** Sharing, Theming, and Paywall Polish — Share sheet, premium gating, and UI polish. *(Complete)*
- ✅ **Step 7:** Widget Development — WidgetKit integration, always displays the last quote seen in the app. *(Complete 2025-04-18)*
- 🟡 **Step 8:** Onboarding Flow — Guide new users, collect preferences, and introduce premium features. *(Ongoing)*
- ⬜ **Step 9:** Favorites Feature — Allow users to save and revisit liked quotes. *(Todo)*
- ⬜ **Step 10:** User-Generated Quotes — Premium users can create and submit their own quotes. *(Todo)*
- ⬜ **Step 11:** Analytics & Daily Notifications — Track usage and deliver daily quotes via notification. *(Todo)*
- ⬜ **Step 12:** Theming & Styling — Finalize cohesive design and polish UI. *(Todo)*
- ⬜ **Step 13:** Testing & Quality Assurance — Unit tests and UI tests for critical flows. *(Todo)*
- ⬜ **Step 14:** Final Review & Launch — App Store submission, analytics, and post-launch improvements. *(Todo)*
- 🟦 **Ongoing/Future:** Advanced widget customization, additional sharing options, feature expansion based on user feedback. *(Planned)*

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