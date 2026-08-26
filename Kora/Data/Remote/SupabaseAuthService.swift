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

    private let client = SupabaseClientProvider.client

    func restoreSession() async -> Session? {
        guard let cached = client.auth.currentSession else { return nil }

        do {
            return try await client.auth.session
        } catch {
            return cached
        }
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
