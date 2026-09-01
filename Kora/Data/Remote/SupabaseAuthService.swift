//
//  SupabaseAuthService.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

import CryptoKit
import Foundation
import Supabase

struct SupabaseAuthService {
    
    // do + try/catch = handle error here
    // try inside throws = pass error to caller
    // try? = replace error with nil

    private let client = SupabaseClientProvider.client

    func restoreSession() async -> Session? {
        // checks if any cached session, nil could mean never signed in, signed out, data deleted etc.
        guard let cached = client.auth.currentSession else { return nil }

        do {
            // look for valid session
            return try await client.auth.session
        } catch {
            return cached
        }
    }
    
    @discardableResult
    func signInWithGoogle(idToken: String, accessToken: String, nonce: String) async throws -> Session {
        try await client.auth.signInWithIdToken(
            credentials: .init(provider: .google, idToken: idToken, accessToken: accessToken, nonce: nonce)
        )
    }
    
    func session(from url: URL) async throws -> Session {
        try await client.auth.session(from: url)
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    @discardableResult
    func signInWithApple(idToken: String, nonce: String) async throws -> Session {
        try await client.auth.signInWithIdToken(
            credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
        )
    }

    static func randomNonce(byteCount: Int = 32) -> String {
        var bytes = [UInt8](repeating: 0, count: byteCount)
        let status = SecRandomCopyBytes(kSecRandomDefault, byteCount, &bytes)
        guard status == errSecSuccess else {
            fatalError("SecRandomCopyBytes failed with status \(status)")
        }
        return bytes.map { String(format: "%02x", $0) }.joined()
    }

    static func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }
}
