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
        client
            .database
            .from("quotes")
            .select()
            .execute { result in
                switch result {
                case .success(let response):
                    do {
                        let quotes = try response.decoded(to: [Quote].self)
                        completion(.success(quotes))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}