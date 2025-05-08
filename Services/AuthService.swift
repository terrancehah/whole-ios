// AuthService.swift
// Manages user authentication, sign-in, sign-up, password reset, and session state.

import Foundation
import Supabase

/// Service to handle user authentication and session management.
@MainActor
final class AuthService: ObservableObject {
    /// Published property to track the current session.
    @Published var session: Session?
    /// Published property to track the current user.
    @Published var user: User?
    /// Published property to signal that initial auth checks are complete.
    @Published var isInitialized: Bool = false

    // Store the subscription as an optional Any, since the SDK does not require a specific type.
    private var authSubscription: Any?
    private var hasProcessedFirstAuthChangeEvent: Bool = false // New flag
    
    static let shared = AuthService()
    
    private init() {
        print("[DEBUG] AuthService init: Starting initialization.")
        Task {
            var sessionRestoredFromKeychain = false
            // Prioritize Keychain for session restoration
            if let accessToken = KeychainHelper.shared.get("supabase_access_token"),
               let refreshToken = KeychainHelper.shared.get("supabase_refresh_token") {
                print("[DEBUG] AuthService init: Found tokens in Keychain. Attempting to set session.")
                do {
                    // Set the session in the Supabase client using the retrieved tokens
                    try await SupabaseService.shared.client.auth.setSession(accessToken: accessToken, refreshToken: refreshToken)
                    self.session = SupabaseService.shared.client.auth.currentSession
                    self.user = SupabaseService.shared.client.auth.currentUser
                    if let user = self.user {
                        print("[DEBUG] AuthService init: Session successfully set from Keychain for user ID: \(user.id.uuidString)")
                        sessionRestoredFromKeychain = true
                    } else {
                        print("[WARNING] AuthService init: setSession from Keychain completed, but user is still nil.")
                    }
                } catch {
                    print("[ERROR] AuthService init: Failed to set session from Keychain tokens: \(error.localizedDescription). Clearing invalid tokens.")
                    KeychainHelper.shared.delete("supabase_access_token")
                    KeychainHelper.shared.delete("supabase_refresh_token")
                }
            } else {
                print("[DEBUG] AuthService init: No tokens found in Keychain. Will rely on Supabase default or new login.")
            }
            // Setup listener and finalize initialization
            await setupAuthStateChangeListener(keychainSuccess: sessionRestoredFromKeychain)
            // self.isInitialized = true // MOVED: Do not set here anymore
            // print("[DEBUG] AuthService init: Initialization complete. isInitialized = true.") // MOVED
        }
    }

    // Extracted method to reduce nesting and clarify flow
    private func setupAuthStateChangeListener(keychainSuccess: Bool) async {
        if !keychainSuccess {
            // If keychain restore didn't happen or failed, try to load from Supabase default store as a fallback / initial check
            // This was the previous logic before keychain prioritization.
            let initialSession = SupabaseService.shared.client.auth.currentSession
            let initialUser = SupabaseService.shared.client.auth.currentUser
            self.session = initialSession
            self.user = initialUser
            if initialSession != nil {
                print("[DEBUG] AuthService setupAuthStateChangeListener: Synchronously found session via Supabase default for user ID: \(initialSession!.user.id.uuidString)")
            } else {
                print("[DEBUG] AuthService setupAuthStateChangeListener: No session found via Supabase default store.")
            }
        }

        // Listen for authentication state changes
        self.authSubscription = await SupabaseService.shared.client.auth.onAuthStateChange { [weak self] event, session in
            Task { @MainActor in // Ensure updates are on main actor
                guard let self = self else { return }
                print("[DEBUG] AuthService onAuthStateChange: Event - \(event), Session User ID - \(session?.user.id.uuidString ?? "NIL")")
                self.session = session
                self.user = session?.user

                if !self.hasProcessedFirstAuthChangeEvent {
                    self.hasProcessedFirstAuthChangeEvent = true
                    self.isInitialized = true
                    print("[DEBUG] AuthService: First auth change event processed. isInitialized = true.")
                }
            }
        }
    }
    
    deinit {
        // Remove the auth subscription when the service is deinitialized, if possible.
        (authSubscription as? Removable)?.remove()
    }
    
    /// Sign up a new user with email and password.
    /// Returns the full AuthResponse from Supabase.
    func signUp(email: String, password: String) async throws -> AuthResponse {
        // The Supabase SDK returns AuthResponse, not Session.
        let response = try await SupabaseService.shared.client.auth.signUp(email: email, password: password)
        self.session = response.session
        return response
    }

    /// Signs in a Supabase anonymous user using the built-in mechanism.
    /// Stores session and refresh tokens securely in Keychain for future silent login.
    func signInSupabaseAnonymous() async throws -> User? {
        // Call Supabase's built-in anonymous sign-in API
        let session = try await SupabaseService.shared.client.auth.signInAnonymously()
        // Store session and refresh tokens for persistent login (tokens are non-optional)
        KeychainHelper.shared.save(session.accessToken, forKey: "supabase_access_token")
        KeychainHelper.shared.save(session.refreshToken, forKey: "supabase_refresh_token")
        // Update local session and user state
        self.session = session
        self.user = session.user
        return session.user
    }

    /// Sign in an existing user.
    /// Returns the session if successful.
    func signIn(email: String, password: String) async throws -> Session {
        // The Supabase SDK returns Session directly (not AuthResponse).
        let session = try await SupabaseService.shared.client.auth.signIn(email: email, password: password)
        self.session = session
        return session
    }

    /// Sign out the current user.
    func signOut() async throws {
        try await SupabaseService.shared.client.auth.signOut()
        self.session = nil
        self.user = nil
    }

    /// Sends a password reset email to the specified address.
    /// - Parameter email: The email address of the user requesting a password reset.
    func resetPassword(email: String) async throws {
        // The latest SDK expects a single parameter, not a labeled one.
        try await SupabaseService.shared.client.auth.resetPasswordForEmail(email)
    }
}

// Protocol for removable subscriptions, if needed
protocol Removable {
    func remove()
}
