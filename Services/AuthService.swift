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

    // Store the subscription as an optional Any, since the SDK does not require a specific type.
    private var authSubscription: Any?
    
    init() {
        // Listen for authentication state changes using the latest Supabase SDK API.
        Task {
            self.authSubscription = await SupabaseService.shared.client.auth.onAuthStateChange { [weak self] event, session in
                // Ensure updates to published properties are performed on the main actor.
                Task { @MainActor in
                    self?.session = session
                    self?.user = session?.user
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
