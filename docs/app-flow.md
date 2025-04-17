# App Flow for Whole

## 1. Launch and Onboarding
- **Launch Screen**
  - Purpose: Welcomes users and establishes branding.
  - Details:
    - Displays the app logo or branding for a few seconds before transitioning to onboarding.

- **Onboarding Screens**
  - Objective: Introduce the app and collect user preferences to personalize the experience.
  - Screens:
    1. Welcome Message and App Purpose
       - Brief text: "Welcome to Whole – your daily dose of inspiration in English and Chinese."
       - Highlights the app's value: bilingual quotes for motivation and reflection.
    2. Widget Feature Introduction
       - Explains the lock screen/standby mode widget: "Get daily quotes without unlocking your phone."
       - Includes a prompt to install the widget, with a "Later" option to skip.
    3. Interactive User Preference Form
       - Quote Categories: Multiple-choice selection (e.g., Inspiration, Love, Success, Wisdom).
       - Name: Optional text input with a "Skip" button.
       - Gender: Optional single-choice (e.g., Male, Female, Other, Prefer Not to Say) with a "Skip" option.
       - Goals: Multiple-choice (e.g., Personal Growth, Career Success, Inner Peace).
       - Additional Customization Questions: Optional multiple-choice questions.
    4. Subscription Model Introduction
       - Brief overview: "Unlock unlimited quotes and premium features with a 7-day free trial."
       - Transitions to the paywall screen.

- **Paywall Screen**
  - Purpose: Encourage subscription while offering a free trial or limited access.
  - Details:
    - Options:
      - "Start 7-Day Free Trial" button.
      - "Subscribe Now" with monthly and yearly pricing displayed.
      - Reminder Toggle: "Remind me before trial ends" (default: on).
      - Close Button: Access free version with limitations.

## 2. Main Interface
- **Quote Cards**
  - Display: Single quote per card with English text on top, Chinese translation below.
  - Interaction: Swipe left or right to view new quotes.
  - Buttons:
    - Like: Saves quote to Favorites tab.
    - Share: Generates shareable image (watermarked for free users).
  - Free User Limit: 10 quotes/day with subscription prompt.

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
  - Default theme: Serene Minimalism.
- **Error Handling:**
  - Native-style retry button for load failures.

## 4. Settings Screen
- **Quote Categories**
  - Edit or update preferred categories.
  - Mirrors onboarding selections.

- **Customization**
  - App background options.
  - Theme selection (light/dark mode).
  - Font style choices.
  - Premium features locked for free users.

- **Subscription Management**
  - View current status.
  - Upgrade/downgrade options.
  - Cancel subscription functionality.

- **Widget Configuration**
  - Set widget preferences.
  - Category selection for displayed quotes.

- **Notifications**
  - Daily quote timing adjustment.
  - Default set to 8 AM.

## 5. Widget
- **Lock Screen and Standby Mode**
  - Display: One bilingual quote, updated daily.
  - Categories: Based on user preferences.
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

## 8. AuthService
- **Password Reset:**
  - The AuthService provides a method to send password reset emails via Supabase.
  - Usage: Call `resetPassword(email:completion:)` with the user's email address.

---

### Data Models: Quote

- **Swift Model:**
  - File: `Models/QuoteModel.swift`
  - Structure:
    - `id: String` (UUID)
    - `englishText: String`
    - `chineseText: String`
    - `categories: [String]`
    - `createdAt: Date?`
    - `createdBy: String?`
- **Maps to Supabase table:** `quotes`
- **Coding keys** ensure correct mapping between Swift and Supabase/JSON fields.

### Data Models: UserProfile
- **Swift Model:**
  - File: `Models/UserModel.swift`
  - Structure:
    - `id: String` (UUID)
    - `email: String`
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
    - `id: String` (UUID)
    - `userId: String`
    - `englishText: String`
    - `chineseText: String`
    - `createdAt: Date?`
- **Maps to Supabase table:** `userquotes`

### View Models
- **QuoteViewModel:**
  - File: `ViewModels/QuoteViewModel.swift`
  - Handles fetching and state for quotes.

---