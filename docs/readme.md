# Whole

**Whole** is an iOS application that displays bilingual (English and Chinese) quotes on your lock screen and standby mode, providing daily inspiration and motivation.

---

## Features
- Browse bilingual quotes with horizontal swipe.
- Like and unlike quotes, with real-time sync to Supabase backend.
- Robust error handling for all quote interactions.
- Quote card and sharing support user-selectable themes (Serene Minimalism, Elegant Monochrome, Soft Pastel Elegance).
- All other UI follows system light/dark mode for maximum consistency with iOS.
- Theme selection UI in CustomizationView; theme state managed globally via ThemeManager.
- [Planned] Sharing and paywall features.

---

## MVP Feature Summary (2025-04-17)
- Horizontal quote browsing (carousel style), 10/day for free users.
- Like = Save, with native feedback.
- Share via native iOS share sheet.
- Popups for like/limit reached.
- Paywall CTA and theme switch on main UI.
- Serene Minimalism default theme.

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