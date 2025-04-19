// UserProfileViewModel.swift
// ObservableObject for managing and syncing the current user's profile and subscription state.

import Foundation
import Combine

/// ViewModel to manage fetching and state of the current user's profile from Supabase.
final class UserProfileViewModel: ObservableObject {
    /// Published user profile for use in the UI.
    @Published var user: UserProfile
    /// Published property to track loading state.
    @Published var isLoading: Bool = false
    /// Published property for error messages.
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    /// Initialize with a default or placeholder user profile.
    init(user: UserProfile = UserProfile.placeholder) {
        self.user = user
    }

    /// Fetch the current user's profile from Supabase using SupabaseService.
    func fetchUserProfile(userId: String) {
        isLoading = true
        errorMessage = nil
        SupabaseService.shared.fetchUserProfile(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let profile):
                    self?.user = profile
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    /// Refresh the user profile (call after purchase/restore or on app launch).
    func refresh(userId: String) {
        fetchUserProfile(userId: userId)
    }

    // MARK: - Mock for Previews
    #if DEBUG
    static var mock: UserProfileViewModel {
        UserProfileViewModel(user: UserProfile.mock)
    }
    #endif
}
