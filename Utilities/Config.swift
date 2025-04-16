// Config.swift
// Stores environment-specific configuration for the Whole app.
// This file contains sensitive information such as API keys and endpoints.
// Do NOT commit this file to public repositories if you add secrets in the future.
//
// Usage:
//   Use Config.supabaseURL and Config.supabaseAnonKey wherever you need to initialize Supabase clients or make API calls.
//   This centralizes configuration and makes it easy to switch environments (dev, prod).

import Foundation

struct Config {
    // Supabase Project URL
    // This is the base URL for all Supabase API calls for the Whole app.
    static let supabaseURL = "https://emlzuiaaohergjumcvfp.supabase.co"

    // Supabase anon/public API key
    // This key is safe for client-side use, but should still be kept private if possible.
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVtbHp1aWFhb2hlcmdqdW1jdmZwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ3NjkxNzAsImV4cCI6MjA2MDM0NTE3MH0.ykW_Pe2LfJWFnALqQy2XDnOTVI0J5iGZqJEBCUNrl_0"
}
