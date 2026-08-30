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

    private let profileService = SupabaseProfile()

    var username = "" {
        didSet { validate() }
    }
    var status: Status = .idle
    var isSubmitting = false
    var errorMessage: String?

    var canSubmit: Bool {
        status == .available && !isSubmitting
    }
    
    var message: String {
        switch status {
        case .idle, .checking: Self.hint
        case .invalid(let reason): reason
        case .available: "Username is available."
        case .taken: "That username is taken."
        }
    }
    
    func validate() {
        let name = normalized(username)
        if name.isEmpty {
            status = .idle
        } else if let reason = validationError(for: name) {
            status = .invalid(reason)
        } else {
            status = .checking
        }
    }

    func checkAvailability() async {
        let name = normalized(username)
        guard !name.isEmpty, validationError(for: name) == nil else { return }

        do {
            status = try await profileService.isUsernameAvailable(name) ? .available : .taken
        } catch {
            errorMessage = "Couldn't check that username. Check your connection."
        }
    }

    func submit(userId: UUID) async -> UserProfile? {
        let name = normalized(username)
        guard validationError(for: name) == nil else { return nil }

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
        raw.trimmingCharacters(in: .whitespacesAndNewlines)
            .precomposedStringWithCanonicalMapping
    }

    private func validationError(for name: String) -> String? {
        if name.count < 3 { return "At least 3 characters." }
        if name.count > 20 { return "20 characters maximum." }
        if !name.unicodeScalars.allSatisfy({ Self.allowed.contains($0) }) { return Self.hint }
        return nil
    }
}
