//
//  AuthViewModel.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

import AuthenticationServices
import GoogleSignIn
import Observation
import Supabase
import UIKit

@MainActor
@Observable
final class AuthViewModel {

    private let authService = SupabaseAuthService()
    private var currentNonce: String?

    var isLoading = false
    var errorMessage: String?

    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = SupabaseAuthService.randomNonce()
        currentNonce = nonce
        request.requestedScopes = [.email]
        request.nonce = SupabaseAuthService.sha256(nonce)
    }

    func signInWithGoogle() async -> Session? {
        errorMessage = nil

        guard let presenter = rootViewController else {
            errorMessage = "Couldn't open Google sign-in."
            return nil
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let nonce = SupabaseAuthService.randomNonce()

            let result = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: presenter,
                hint: nil,
                additionalScopes: nil,
                nonce: SupabaseAuthService.sha256(nonce)
            )

            guard let idToken = result.user.idToken?.tokenString else {
                errorMessage = "Google didn't return an identity token."
                return nil
            }

            return try await authService.signInWithGoogle(
                idToken: idToken,
                accessToken: result.user.accessToken.tokenString,
                nonce: nonce
            )
        } catch {
            if (error as? GIDSignInError)?.code != .canceled {
                errorMessage = "Google sign-in didn't complete. Try again."
            }
            return nil
        }
    }

    private var rootViewController: UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController
    }

    func handleAppleCompletion(_ result: Result<ASAuthorization, Error>) async -> Session? {
        errorMessage = nil

        switch result {
        case .failure:
            return nil

        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                errorMessage = "Apple returned an unexpected credential."
                return nil
            }

            guard let tokenData = credential.identityToken,
                  let idToken = String(data: tokenData, encoding: .utf8) else {
                errorMessage = "Apple didn't return an identity token."
                return nil
            }

            guard let nonce = currentNonce else {
                errorMessage = "This sign-in request expired. Try again."
                return nil
            }
            currentNonce = nil

            isLoading = true
            defer { isLoading = false }

            do {
                return try await authService.signInWithApple(idToken: idToken, nonce: nonce)
            } catch {
                errorMessage = "Couldn't sign in. Check your connection and try again."
                return nil
            }
        }
    }
}
