//
//  EmailLoginView.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-09-04.
//

import SwiftUI

struct EmailLoginView: View {

    let onSignedIn: () -> Void

    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss

    @State private var vm = AuthViewModel()
    @State private var email: String = ""
    @State private var password: String = ""

    private var canSubmit: Bool {
        !email.isEmpty && !password.isEmpty && !vm.isLoading
    }

    var body: some View {
        VStack(spacing: 42) {
            VStack(spacing: 16) {
                Text("Welcome back")
                    .font(.system(size: 22, weight: .medium))
                    .fontDesign(.monospaced)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)

                Text("Sign in with your email and password.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.secondary)
                    .fontDesign(.monospaced)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)
            }

            VStack(alignment: .leading, spacing: 12) {
                TextField("Email", text: $email)
                    .font(.system(size: 18, weight: .regular))
                    .keyboardType(.emailAddress)
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(Color(hex: "#090909"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator).opacity(0.5), lineWidth: 0.5))

                SecureField("Password", text: $password)
                    .font(.system(size: 18, weight: .regular))
                    .textContentType(.password)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(Color(hex: "#090909"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator).opacity(0.5), lineWidth: 0.5))

                if let errorMessage = vm.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 4)
                }
            }
            .onChange(of: email) { _, _ in vm.errorMessage = nil }
            .onChange(of: password) { _, _ in vm.errorMessage = nil }

            Button {
                Task {
                    if let session = await vm.logIn(email: email, password: password) {
                        coordinator.session = session
                        onSignedIn()
                    }
                }
            } label: {
                Text("Continue")
                    .font(.system(size: 18, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(canSubmit ? Color.white : Color(hex: "#090909"))
                    .foregroundStyle(canSubmit ? Color.black : Color(.separator))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator).opacity(0.5), lineWidth: 0.5))
                    .animation(.smooth(duration: 0.2), value: canSubmit)
            }
            .buttonStyle(.plain)
            .allowsHitTesting(canSubmit)
        }
        .padding(.horizontal, 22)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden(true)
        .overlay(alignment: .topLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 44, height: 44, alignment: .topLeading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.leading, 22)
            .padding(.top, 22)
        }
    }
}

#Preview {
    NavigationStack {
        EmailLoginView(onSignedIn: {})
            .environment(AppCoordinator())
    }
}
