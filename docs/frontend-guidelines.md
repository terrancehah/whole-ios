# Frontend Guidelines for Whole

## 1. Technology
- SwiftUI for building the user interface.
- WidgetKit for creating the widget.

## 2. Design Principles
- **Minimalism:** Focus on the quotes with clean backgrounds.
- **Readability:** Ensure text is legible in both languages.
- **Consistency:** Use consistent fonts, colors, and spacing.
- **Accessibility:** Support dynamic type and high contrast modes.

## 3. UI Components
- Use v0 by Vercel to generate SwiftUI components.
- Customize components to fit the app's theme.

## 4. Themes
- Support light and dark modes.
- Premium users can access additional themes.

## 5. Fonts
- Use system fonts or custom fonts that support both English and Chinese characters.
- For Chinese, consider fonts like PingFang SC.

## 6. Widget Design
- Ensure the widget looks good in small, medium, and large sizes.
- Optimize for lock screen and standby mode displays.

## 7. UI Style Options & Theming

Whole supports multiple visual styles to suit different user preferences. For launch, we recommend starting with **Serene Minimalism** as the default. The other styles can be offered as alternative themes (e.g., for premium users) in the future.

### 7.1 Serene Minimalism (Default)
- **Concept:** Soft, calming design with whitespace and subtle gradients for a tranquil, timeless experience.
- **Background:** Off-white (#F8F9FA) with a subtle linear gradient (#F8F9FA → #EDEFF1).
- **Quote Card:** Rounded rectangle, minimal shadow, pure white with slight glass effect.
- **Typography:**
  - English: Georgia or serif, #2D3748, 20px
  - Chinese: PingFang SC or clean sans-serif, #C9D1D9, 18px
  - Line spacing: 1.5x
- **Buttons:**
  - Primary: Use accent color from Serene Minimalism palette (#ff9f68) for background, white text, and rounded corners (12).
  - Secondary: Use secondary color (#ff784f) for background, white or dark text depending on contrast, and rounded corners (12).
  - Avoid pastel blue. All button colors must reference the Serene Minimalism palette.
  - Button states (pressed/disabled) use lighter/darker shades of the above.
- **Navigation:**
  - Icons and highlights use accent color (#ff9f68).
  - Active tab uses secondary color (#ff784f).
- **Vibe:** Light, airy, serene, quote as centerpiece

### 7.2 Elegant Monochrome
- **Concept:** Bold, minimal monochrome palette with a single accent color for key actions.
- **Background:** Pure black (dark mode), pure white (light mode)
- **Quote Card:** Sharp rectangle, no border/shadow, blends with background
- **Typography:**
  - English: Helvetica Neue Bold, 22px
  - Chinese: Noto Sans SC, 18px
  - Color: #FFFFFF (dark), #000000 (light)
  - Line spacing: 1.4x
- **Buttons:** Heart icon (#FFFFFF/#000000, filled #FF6B6B when liked), share icon
- **Navigation:** Transparent bars, icons in monochrome, accent color (#FF6B6B) for active tab
- **Vibe:** Stark, modern, high-contrast, sophisticated

### 7.3 Soft Pastel Elegance
- **Concept:** Gentle pastel palette, rounded elements, warm and inviting feel
- **Background:** Light pastel gray (#F7FAFC) with subtle radial gradient (#F7FAFC → #E2E8F0)
- **Quote Card:** Rounded rectangle (16px), soft shadow, pastel off-white with faint overlay
- **Typography:**
  - English: Lora, 20px, #2D3748
  - Chinese: Source Han Sans, 18px, #C9D1D9
  - Line spacing: 1.6x
- **Buttons:** Heart icon pastel blue (#A3BFFA, filled #FBB6CE when liked), share icon pastel blue
- **Navigation:** Pastel blue icons, active tab pastel purple (#B794F4)
- **Vibe:** Warm, approachable, elegant, friendly

### 7.4 Theme Switching
- The app is designed to support easy theme switching in the future.
- Premium users may unlock additional themes (e.g., Elegant Monochrome, Soft Pastel Elegance).
- All styles follow the core design principles: minimalism, readability, consistency, accessibility.

## 8. Quote Browsing Interface (MVP)
- Horizontal, non-dismissable swipe (carousel) for quotes.
- Like = Save; heart icon fills and bottom popup confirms.
- Share uses native iOS share sheet with quote image preview.
- Daily swipe limit (10 for free users), native popup when limit hit.
- Retry button for errors (native style).
- Theme switcher and settings buttons on main UI.
- Paywall CTA appears/highlights after limit is reached.
- Default: Serene Minimalism theme.

## 9. Onboarding UI
### 9.1 Onboarding UI (UPDATED)
- Onboarding is modular, using `OnboardingView.swift` and subviews for each step.
- Category selection uses the `QuoteCategory` enum for type safety and consistency.
- All user input is bound to the view model and validated.
- Preferences are saved using the new `UserPreferences` model.

## 9. Onboarding Flow & Data Sync
- The onboarding flow is modular and guides users through welcome, widget intro, preferences, notification settings, and subscription intro steps.
- User profile and preferences are saved to Supabase using dedicated insert methods (`insertUserProfile`, `insertUserPreferences`).
- Notification permission is requested only if notifications are enabled by the user.
- Error handling ensures onboarding only completes if both inserts succeed.
- All onboarding and settings flows use the `UserPreferences` model for consistency.

## 10. Premium Gating Logic
- **Premium gating logic is enforced and documented in code.**
  - All premium actions (theme, sharing, unlimited swipes) are gated and trigger the paywall for free users.
  - Lock icons and paywall CTAs are used for clear UX.
  - See `QuoteListView.swift`, `CustomizationView.swift`, and `QuoteImageGenerator.swift` for implementation and comments.

## 11. Favorites Tab
- **Favorites Tab:**
  - Users can access a dedicated Favorites tab to see all their liked quotes.
  - The tab uses a minimal, modern list UI with swipe-to-remove and empty/error states.
  - All logic is model-driven and robust.

## 12. User Quote Editor
- **User Quote Editor:**
  - Premium users access a dedicated quote creation screen with a soft, minimal UI.
  - Editor uses clear fields, pastel category chips, and robust validation.
  - All user input is validated and commented for maintainability.

## 13. Identifier Handling
- All models, view models, and services must use `UUID` for all identifiers (userId, quoteId, etc.).
- Use `.uuidString` only when interacting with the backend (Supabase).
- All sample/mock data and previews must use `UUID()` for IDs.

## 14. Widget Guidelines
- Widget demo data must use UUID for quote IDs, matching the main app.

## 15. SwiftUI Performance Best Practices
- For large or complex SwiftUI views (such as quote carousels), extract subviews and break up complex expressions (e.g., ForEach with chained enumerated/prefix) into computed properties or helper views.
- This approach is now used in `QuoteListView.swift` for the main TabView and overlays, resolving type-checking errors and improving code clarity.

## 16. Quote List UI Updates (2025-04-29)

- The horizontal scroll indicator (dots) below the quotes has been removed for a cleaner look.
- The background color of the quote list screen is now explicitly set to `#ffeedf` for full visual consistency, regardless of theme logic.
- All floating corner buttons (e.g., star, settings) now have a shadow for depth, matching the style of other floating buttons.

Refer to `QuoteListView.swift` for implementation details.

## 17. QuoteListView
- All buttons use a corner radius of 12 and have consistent shadows for visual polish.
- QuoteListView fills the entire screen for a modern, immersive experience.
- Chinese quote text uses a lighter color from the palette for improved readability.
- Duplicate buttons and error popups are removed for a cleaner UI.

---

> **Note:** For implementation, start with Serene Minimalism. Use the other styles as reference for future expansion.