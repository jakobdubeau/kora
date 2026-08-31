//
//  OnboardingViewModel.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-08-30.
//

import Foundation
import Observation

@MainActor
@Observable
final class OnboardingViewModel {

    enum Status: Equatable {
        case idle
        case invalid(String)
        case checking
        case available
        case taken
    }

    private static let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
    private static let hint = "Please only use letters, numbers, or underscores."

    private let profileService = SupabaseProfileService()

    var username = "" {
        didSet { validate() }
    }
    var status: Status = .idle
    var isSubmitting = false
    var errorMessage: String?

    var message: String {
        switch status {
        case .idle, .checking: Self.hint
        case .invalid(let reason): reason
        case .available: "Username is available."
        case .taken: "That username is taken."
        }
    }
    
    func validate() {
        errorMessage = nil
        
        let name = normalized(username)

        if name.isEmpty {
            status = .idle
        } else if !name.unicodeScalars.allSatisfy({ Self.allowed.contains($0) }) {
            status = .invalid(Self.hint)
        } else if name.count < 3 {
            status = .idle
        } else if let reason = validationError(for: name) {
            status = .invalid(reason)
        } else if status != .available {
            status = .checking
        }
    }

    func tooShort() {
        let name = normalized(username)
        guard !name.isEmpty, name.count < 3, let reason = validationError(for: name) else { return }

        status = .invalid(reason)
    }

    func checkAvailability() async {
        let name = normalized(username)
        guard !name.isEmpty, validationError(for: name) == nil else { return }

        do {
            status = try await profileService.isUsernameAvailable(name) ? .available : .taken
            errorMessage = nil
        } catch {
            guard !Task.isCancelled else { return }
            errorMessage = "Couldn't check that username. Check your connection."
        }
    }

    func submit(userId: UUID) async -> UserProfile? {
        let name = normalized(username)

        if let reason = validationError(for: name) {
            status = .invalid(reason)
            return nil
        }

        errorMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            return try await profileService.createProfile(id: userId, username: name)
        } catch ProfileError.usernameTaken {
            status = .taken
            return nil
        } catch {
            errorMessage = "Couldn't save your username. Try again."
            return nil
        }
    }

    private func normalized(_ raw: String) -> String {
        raw.precomposedStringWithCanonicalMapping
    }

    private func validationError(for name: String) -> String? {
        if !name.unicodeScalars.allSatisfy({ Self.allowed.contains($0) }) { return Self.hint }
        if name.count < 3 { return "At least 3 characters." }
        if name.count > 20 { return "20 characters maximum." }
        return nil
    }
}
