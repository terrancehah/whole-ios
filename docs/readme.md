# Whole

**Whole** is an iOS application that displays bilingual (English and Chinese) quotes on your lock screen and standby mode, providing daily inspiration and motivation.

---

## Features
- **Daily Quotes**: Receive a new bilingual quote each day directly on your lock screen.
- **Customizable Categories**: Select preferred quote categories for a personalized experience.
- **Premium Subscriptions**: Unlock unlimited quotes, remove watermarks, and access premium customization options.
- **Share Quotes**: Generate and share quote images on social media (with optional watermarks for free users).

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

### Backend:
- Use Supabase's Swift client for all backend interactions (authentication, database, etc.).

---

## Contributing
Please read the contribution guidelines before submitting pull requests.