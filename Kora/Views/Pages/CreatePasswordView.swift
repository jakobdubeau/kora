//
//  CreatePasswordView.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-09-04.
//

import SwiftUI

struct CreatePasswordView: View {

    let onCreated: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var vm = AuthViewModel()
    @State private var password: String = ""
    @FocusState private var focused: Bool

    private var requirements: [(label: String, met: Bool)] {
        [
            ("At least 8 characters", password.count >= 8),
            ("One number", password.contains(where: \.isNumber)),
            ("One symbol", password.contains { $0.isPunctuation || $0.isSymbol })
        ]
    }

    private var canSubmit: Bool {
        requirements.allSatisfy(\.met) && !vm.isLoading
    }

    var body: some View {
        VStack(spacing: 42) {
            VStack(spacing: 16) {
                Text("Create a password")
                    .font(.system(size: 22, weight: .medium))
                    .fontDesign(.monospaced)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)

                Text("You'll use this to sign in next time.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.secondary)
                    .fontDesign(.monospaced)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)
            }

            VStack(alignment: .leading, spacing: 12) {
                SecureField("Password", text: $password)
                    .font(.system(size: 18, weight: .regular))
                    .textContentType(.newPassword)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focused)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(Color(hex: "#090909"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator).opacity(0.5), lineWidth: 0.5))
                    .onChange(of: password) { _, _ in
                        vm.errorMessage = nil
                    }

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(requirements, id: \.label) { requirement in
                        HStack(spacing: 10) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(requirement.met ? Color.white : Color(hex: "#090909"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(Color(.separator).opacity(0.5), lineWidth: 0.5)
                                )
                                .frame(width: 14, height: 14)

                            Text(requirement.label)
                                .foregroundStyle(requirement.met ? Color.primary.opacity(0.8) : Color.secondary)

                            Spacer()
                        }
                        .font(.system(size: 13, weight: .medium))
                        .animation(.smooth(duration: 0.2), value: requirement.met)
                    }

                    if let errorMessage = vm.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.red)
                    }
                }
                .padding(.leading, 4)
            }

            Button {
                Task {
                    if await vm.setPassword(password) {
                        onCreated()
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
        CreatePasswordView(onCreated: {})
    }
}
