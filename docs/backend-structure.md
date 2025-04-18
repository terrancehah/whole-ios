# Backend Structure (Supabase Schema)

This document describes the current schema and access policies for the Supabase backend powering the Whole app. Keep this in sync with the actual database and codebase.

---

## Tables

### 1. `quotes`
- **Purpose:** Stores all curated and user-generated quotes.
- **Columns:**
  - `id`: uuid, primary key, auto-generated
  - `english_text`: text, required
  - `chinese_text`: text, required
  - `categories`: text[], required (e.g., ['Inspiration', 'Love'])
  - **Allowed categories:**
    - Inspiration
    - Love
    - Success
    - Wisdom
    - Motivation
    - Life
    - Happiness
    - Compassion
    - Friends & Family
    - Optimism
- **RLS:**
  - SELECT: Any authenticated user
  - ALL (INSERT/UPDATE/DELETE): Only admins (service_role, supabase_admin)

### 2. `users`
- **Purpose:** Stores user profile and subscription info.
- **Columns:**
  - `id`: uuid, primary key (matches auth.uid)
  - `email`: text, unique, required
  - `name`: text
  - `gender`: text
  - `goals`: text[]
  - `subscription_status`: text (free, trial, monthly, yearly), default 'free'
  - `trial_end_date`: timestamp
  - `subscription_start_date`: timestamp
  - `subscription_end_date`: timestamp
  - `created_at`: timestamp, default now()
  - `updated_at`: timestamp, default now()
- **RLS:**
  - ALL: Only the user (id = auth.uid)
  - INSERT: id must match auth.uid

### 3. `userpreferences`
- **Purpose:** Stores user’s quote category preferences, notification time, widget settings.
- **Columns:**
  - `user_id`: uuid, primary key, references users(id)
  - `selected_categories`: text[], required
  - `notification_time`: text, default '08:00'
- **RLS:**
  - ALL: Only the user (user_id = auth.uid)
  - INSERT: user_id must match auth.uid

### 4. `userquotes`
- **Purpose:** Stores quotes created by users (premium feature).
- **Columns:**
  - `id`: uuid, primary key, auto-generated
  - `user_id`: uuid, references users(id)
  - `english_text`: text, required
  - `chinese_text`: text, required
  - `created_at`: timestamp, default now()
- **RLS:**
  - ALL: Only the user (user_id = auth.uid)
  - INSERT: user_id must match auth.uid

### 5. `liked_quotes`
- **Purpose:** Stores user likes for quotes.
- **Columns:**
  - `id`: uuid, primary key, auto-generated
  - `user_id`: uuid, references users(id)
  - `quote_id`: uuid, references quotes(id)
- **RLS:**
  - ALL: Only the user (user_id = auth.uid)
  - INSERT: user_id must match auth.uid

---

## Row Level Security (RLS) Summary
| Table           | SELECT                    | INSERT                    | UPDATE/DELETE              |
|-----------------|---------------------------|---------------------------|----------------------------|
| quotes          | Authenticated users       | Admin only                | Admin only                 |
| users           | Only self (id = auth.uid) | Only self (id = auth.uid) | Only self (id = auth.uid)  |
| userpreferences | Only self (user_id = auth.uid) | Only self (user_id = auth.uid) | Only self (user_id = auth.uid) |
| userquotes      | Only self (user_id = auth.uid) | Only self (user_id = auth.uid) | Only self (user_id = auth.uid) |
| liked_quotes    | Only self (user_id = auth.uid) | Only self (user_id = auth.uid) | Only self (user_id = auth.uid) |

---

## Quote Like/Save Logic
- Liking a quote saves it to the user's collection (no separate save action).
- Like status is synced immediately to Supabase.
- Free user swipe limit: 10 quotes/day (enforced in app logic).
- Caching of loaded quotes planned for offline browsing.

---

## Quote Model (Swift)

The Swift model representing a quote in the app is defined as follows (see `Models/QuoteModel.swift`):

```swift
struct Quote: Codable, Identifiable {
    let id: String
    let englishText: String
    let chineseText: String
    let categories: [String]
    let createdAt: Date?
    let createdBy: String?
}
```
- `id`: UUID string, matches Supabase `id` column
- `englishText`: English text of the quote (maps to `english_text`)
- `chineseText`: Chinese translation (maps to `chinese_text`)
- `categories`: Array of category strings
- `createdAt`: Creation timestamp (`created_at`)
- `createdBy`: Creator user ID (optional, `created_by`)

> The coding keys in Swift map each property to its Supabase column name for seamless decoding.

---

## User Profile Model (Swift)

The Swift model representing a user profile is defined as follows (see `Models/UserModel.swift`):

```swift
struct UserProfile: Codable, Identifiable {
    let id: String
    let email: String
    let name: String?
    let gender: String?
    let goals: [String]?
    let subscriptionStatus: String
    let trialEndDate: Date?
    let subscriptionStartDate: Date?
    let subscriptionEndDate: Date?
    let createdAt: Date?
    let updatedAt: Date?
}
```
- Maps to the `users` table columns, with coding keys for JSON mapping.

## Subscription Model (Swift)

The subscription fields are also available as a separate model (see `Models/SubscriptionModel.swift`):

```swift
struct Subscription: Codable {
    let status: String
    let trialEndDate: Date?
    let startDate: Date?
    let endDate: Date?
}
```
- Maps to subscription fields in the `users` table.

## UserQuote Model (Swift)

User-generated quotes are represented as follows (see `Models/UserQuoteModel.swift`):

```swift
struct UserQuote: Codable, Identifiable {
    let id: String
    let userId: String
    let englishText: String
    let chineseText: String
    let createdAt: Date?
}
```
- Maps to the `userquotes` table columns.

## QuoteViewModel (Swift)

The view model for managing quotes is defined as follows (see `ViewModels/QuoteViewModel.swift`):

```swift
final class QuoteViewModel: ObservableObject {
    @Published var quotes: [Quote] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    // ...
}
```
- Handles fetching and state for quotes in the UI.

---

## Quotes Table: CSV Import Format

- The `categories` column in the `quotes` table should be of type `text`.
- For CSV import, use square brackets with comma-separated values for `categories`, e.g., `["Inspiration"]` or `[Love,Compassion]`.
- This format is compatible with Supabase's CSV importer for a text column and avoids errors caused by array or curly brace formats.
- **Example CSV row:**
  ```csv
  id,english_text,chinese_text,categories
  uuid-123,"Example quote.","示例语录。","[Inspiration,Life]"
  ```
- **Do not** use PostgreSQL array syntax (curly braces) in the CSV for this column.

#### Rationale
This format was chosen because Supabase's CSV importer expects a plain text value for text columns. Using square brackets with comma-separated values allows for easy import and future parsing, while avoiding errors that occur with array or curly brace formats. If you need to support multiple categories, list them within the brackets separated by commas.

---

## Notes
- All access requires authentication.
- No cross-user access is allowed unless explicitly enabled.
- Admins can manage curated quotes; users can only manage their own data.
- Update this document whenever you change the database schema or policies.