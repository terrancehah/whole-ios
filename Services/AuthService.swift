// AuthService.swift
// Manages user authentication, sign-in, sign-up, password reset, and session state.

import Foundation
import Supabase
import Combine

/// Service to handle user authentication and session management.
final class AuthService: ObservableObject {
    /// Published property to track the current session.
    @Published var session: Session?
    /// Published property to track the current user.
    @Published var user: User?

    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Listen for authentication state changes.
        SupabaseService.shared.client.auth.sessionPublisher
            .sink { [weak self] session in
                self?.session = session
                self?.user = session?.user
            }
            .store(in: &cancellables)
    }
    
    /// Sign up a new user with email and password.
    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        SupabaseService.shared.client.auth.signUp(email: email, password: password) { result in
            switch result {
            case .success(let session):
                self.session = session
                self.user = session.user
                completion(.success(session.user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Sign in an existing user.
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        SupabaseService.shared.client.auth.signIn(email: email, password: password) { result in
            switch result {
            case .success(let session):
                self.session = session
                self.user = session.user
                completion(.success(session.user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Sign out the current user.
    func signOut(completion: @escaping (Error?) -> Void) {
        SupabaseService.shared.client.auth.signOut { error in
            if error == nil {
                self.session = nil
                self.user = nil
            }
            completion(error)
        }
    }

    /// Sends a password reset email to the specified address.
    /// - Parameters:
    ///   - email: The email address of the user requesting a password reset.
    ///   - completion: Completion handler with an optional error.
    func resetPassword(email: String, completion: @escaping (Error?) -> Void) {
        SupabaseService.shared.client.auth.resetPasswordForEmail(email: email) { error in
            completion(error)
        }
    }
}