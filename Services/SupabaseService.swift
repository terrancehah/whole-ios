// SupabaseService.swift
// Handles all communication with Supabase backend (auth, DB, real-time).

import Foundation
import Supabase

/// Singleton service for managing the Supabase client and backend operations.
final class SupabaseService {
    /// Shared instance for global access throughout the app.
    static let shared = SupabaseService()
    
    /// The Supabase client for making API calls (auth, database, storage, etc.).
    let client: SupabaseClient

    /// Private initializer to enforce singleton usage.
    private init() {
        // Initialize the Supabase client with credentials from Config.swift.
        client = SupabaseClient(
            supabaseURL: URL(string: Config.supabaseURL)!,
            supabaseKey: Config.supabaseAnonKey
        )
    }
    
    // MARK: - Example DB Operations (to be expanded as needed)
    
    /// Fetches a list of quotes from the Supabase 'quotes' table.
    /// - Parameter completion: Completion handler with Result<[Quote], Error>
    func fetchQuotes(completion: @escaping (Result<[Quote], Error>) -> Void) {
        // Use a Task to bridge async/await to a callback-based API
        Task {
            do {
                // Fetch the list of quotes from the Supabase 'quotes' table using async/await.
                // Use the .value property to get the decoded array of Quote.
                let quotes: [Quote] = try await client
                    .database
                    .from("quotes")
                    .select()
                    .execute()
                    .value
                completion(.success(quotes))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Liked Quotes Operations
    
    /// Fetches the IDs of quotes liked by a specific user from the 'liked_quotes' table.
    /// - Parameters:
    ///   - userId: The ID of the current user.
    ///   - completion: Completion handler with Result<[String], Error>
    func fetchLikedQuoteIDs(forUser userId: String, completion: @escaping (Result<[String], Error>) -> Void) {
        Task {
            do {
                // Query liked_quotes for all quoteIds liked by this user
                let response: [LikedQuote] = try await client
                    .database
                    .from("liked_quotes")
                    .select()
                    .eq("userId", value: userId)
                    .execute()
                    .value
                // Map to quoteId array
                let quoteIDs = response.map { $0.quoteId }
                completion(.success(quoteIDs))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Likes a quote for a user by inserting into the 'liked_quotes' table.
    /// - Parameters:
    ///   - quoteId: The ID of the quote to like.
    ///   - userId: The ID of the current user.
    ///   - completion: Completion handler with Result<Void, Error>
    func likeQuote(quoteId: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                let insertData = ["userId": userId, "quoteId": quoteId]
                _ = try await client
                    .database
                    .from("liked_quotes")
                    .insert(values: [insertData])
                    .execute()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Unlikes a quote for a user by deleting from the 'liked_quotes' table.
    /// - Parameters:
    ///   - quoteId: The ID of the quote to unlike.
    ///   - userId: The ID of the current user.
    ///   - completion: Completion handler with Result<Void, Error>
    func unlikeQuote(quoteId: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                // Delete the like where both userId and quoteId match
                _ = try await client
                    .database
                    .from("liked_quotes")
                    .delete()
                    .eq("userId", value: userId)
                    .eq("quoteId", value: quoteId)
                    .execute()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - User Profile Operations
    /// Fetches the current user's profile from the 'users' table.
    /// - Parameters:
    ///   - userId: The ID of the user.
    ///   - completion: Completion handler with Result<UserProfile, Error>
    func fetchUserProfile(userId: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        Task {
            do {
                let profiles: [UserProfile] = try await client
                    .database
                    .from("users")
                    .select()
                    .eq("id", value: userId)
                    .limit(1)
                    .execute()
                    .value
                if let profile = profiles.first {
                    completion(.success(profile))
                } else {
                    completion(.failure(NSError(domain: "No user profile found", code: 404)))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}

// MARK: - LikedQuote Model for decoding liked_quotes table
/// Represents a liked quote record for decoding Supabase responses.
struct LikedQuote: Codable {
    let id: String?
    let userId: String
    let quoteId: String
}