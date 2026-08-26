//
//  SupabaseAuthService.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

import Supabase

struct SupabaseAuthService {

    private let client = SupabaseClientProvider.client

    func restoreSession() async -> Session? {
        guard let cached = client.auth.currentSession else { return nil }

        do {
            return try await client.auth.session
        } catch {
            return cached
        }
    }
}
