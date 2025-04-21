# Product Requirements Document (PRD) for Whole MVP

## 1. Introduction

### 1.1 Purpose
This document outlines the requirements for the Minimum Viable Product (MVP) of **Whole**, an iOS application designed to display bilingual (English and Chinese) quotes on the user's lock screen and standby mode.

### 1.2 Scope
The MVP will include core features necessary to validate the app idea, including a widget for quote display, a main interface for browsing quotes, a paywall for subscriptions, and basic sharing functionality.

---

## 2. Product Overview
**Whole** provides users with daily inspiration through carefully curated bilingual quotes. Users can:
- View quotes on their lock screen
- Receive daily notifications
- Select quote categories
- Share quotes on social media

Premium features are unlocked through a subscription, offering unlimited quote access and customization options.

---

## 3. Target Audience
- Users seeking daily inspiration and motivation
- Bilingual individuals interested in English and Chinese quotes
- Followers of the creator on Xiaohongshu

---

## 4. Goals and Objectives
- Validate the app concept through user engagement and feedback
- Achieve **1000 downloads** within the first month
- Convert **10% of users** to paid subscribers

---

## 5. Features and Functionality

### 5.1 Widget
- Displays a bilingual quote on the lock screen and standby mode
- Updates daily with a new, random quote
- (No category selection for MVP)

### 5.2 Main Interface
- Features swipeable cards to browse quotes
- Includes options to save quotes to favorites and share on social media
- Displays English quote on top with Chinese translation below

### 5.3 Quote Browsing Requirements (MVP)
- Horizontal swipe browsing, not dismissable.
- 10 quotes/day limit for free users.
- Like = Save; native feedback popup.
- Share: Native iOS share sheet with quote image.
- Paywall CTA after limit.
- Theme switcher and settings on main UI.
- Caching for offline planned.

### 5.4 Paywall and Subscriptions
- Offers a **7-day free trial** upon first launch
- Provides monthly and yearly subscription options
- Premium features include:
  - Unlimited quote access
  - Watermark removal
  - Premium fonts and themes
  - Ability to create personal quotes

### 5.5 Notifications
- Sends daily notifications with new quotes at a user-set time

### 5.6 Quote Sharing
- Generates shareable quote images (with watermarks for free users)

### 5.7 User-Generated Quotes (Premium)
- Premium users can create and submit bilingual quotes via a dedicated editor.
- The editor uses a modern, minimal UI and robust validation.
- Submitted quotes are saved to the backend and will be subject to moderation in future releases.

### 5.8 Onboarding (COMPLETE)
- Users are greeted, introduced to widgets, select categories (using QuoteCategory enum), and set preferences.
- All onboarding data is saved to Supabase using the UserPreferences model.
- The onboarding flow is implemented and tested.

### 5.9 Favorites
- **Favorites (Liked Quotes):**
  - Users can save quotes as favorites and revisit them in a dedicated tab.
  - Favorites are synced to the backend and persist across devices.
  - Removing a favorite updates both UI and backend in real time.

---

## 6. Technical Requirements
- Compatible with **iOS 14 or later**
- Built using **SwiftUI** for frontend development
- Utilizes **WidgetKit** for widget implementation
- Leverages **Supabase** for backend services (authentication, database)
- Integrates **StoreKit** for in-app purchases
- Uses **UserNotifications** for daily notifications
- Employs **Firebase Analytics** for tracking user behavior

---

## 7. Design Guidelines
- Minimalistic design prioritizing quote readability
- Supports **light and dark modes**
- Uses system fonts or custom fonts supporting English and Chinese
- Ensures consistent UI components generated using **v0 by Vercel**

---

## 8. Success Metrics
- Number of downloads
- Daily active users
- Subscription conversion rate
- User retention rate
- Engagement metrics (e.g., shares, saved quotes)

---

## 9. Timeline
- **MVP Development**: 1 week
- **Testing and Bug Fixing**: 1 week
- **App Store Submission and Launch**: Week 3

*Note: The timeline is ambitious; feature prioritization may be required to meet deadlines.*

---