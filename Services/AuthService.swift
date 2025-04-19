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
    /// Returns the created user if successful.
    func signUp(email: String, password: String) async throws -> User? {
        // The latest Supabase SDK returns AuthResponse, not Session.
        let response = try await SupabaseService.shared.client.auth.signUp(email: email, password: password)
        self.session = response.session
        self.user = response.user
        return response.user
    }

    /// Sign in an existing user.
    /// Returns the signed-in user if successful.
    func signIn(email: String, password: String) async throws -> User? {
        // The latest Supabase SDK returns AuthResponse, not Session.
        let response = try await SupabaseService.shared.client.auth.signIn(email: email, password: password)
        self.session = session
        self.user = response.user
        return response.user
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
