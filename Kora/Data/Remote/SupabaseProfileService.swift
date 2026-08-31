//
//  SupabaseProfileService.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

import Foundation
import Supabase

enum ProfileError: Error {
    case usernameTaken
}

struct SupabaseProfileService {

    private let client = SupabaseClientProvider.client

    func fetchProfile(userId: UUID) async throws -> UserProfile? {
        try await client
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .maybeSingle()
            .execute()
            .value // produces a UserProfile or nil
    }

    func isUsernameAvailable(_ username: String) async throws -> Bool {
        let matches: [UserProfile] = try await client
            .from("profiles")
            .select()
            .ilike("username", pattern: username.replacingOccurrences(of: "_", with: "\\_"))
            .limit(1)
            .execute()
            .value

        return matches.isEmpty
    }

    func createProfile(id: UUID, username: String) async throws -> UserProfile {
        do {
            return try await client
                .from("profiles")
                .insert(UserProfile(id: id, username: username))
                .select()
                .single()
                .execute()
                .value // returns UserProfile
        } catch let error as PostgrestError
            where error.code == "23505" && error.message.contains("profiles_username") {
            throw ProfileError.usernameTaken
        }
    }
}
