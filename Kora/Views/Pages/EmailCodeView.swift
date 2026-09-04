//
//  EmailCodeView.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-09-04.
//

import SwiftUI

struct EmailCodeView: View {

    let email: String
    let onVerified: () -> Void

    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss

    @State private var vm = AuthViewModel()
    @State private var code: String = ""
    @FocusState private var focused: Bool
    @State private var cooldown: Int = 0

    private var canSubmit: Bool {
        code.count == 6 && !vm.isLoading
    }

    var body: some View {
        VStack(spacing: 48) {
            VStack(spacing: 16) {
                Text("Check your email")
                    .font(.system(size: 22, weight: .medium))
                    .fontDesign(.monospaced)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)

                Text("We sent a code to \(email).")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.secondary)
                    .fontDesign(.monospaced)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)
            }

            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    TextField("", text: $code)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .focused($focused)
                        .opacity(0.01)
                        .onChange(of: code) { _, entered in
                            code = String(entered.filter(\.isNumber).prefix(6))
                            vm.errorMessage = nil
                        }

                    HStack(spacing: 8) {
                        ForEach(0..<6, id: \.self) { index in
                            let isActive = focused && index == min(code.count, 5)

                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(hex: "#090909"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color(.separator).opacity(0.5), lineWidth: isActive ? 2 : 0.5)
                                )
                                .overlay(
                                    Text(index < code.count ? String(Array(code)[index]) : "")
                                        .font(.system(size: 20, weight: .medium))
                                        .monospacedDigit()
                                )
                                .frame(height: 52)
                                .animation(.smooth(duration: 0.15), value: isActive)
                        }
                    }
                    .allowsHitTesting(false)
                }
                .contentShape(Rectangle())
                .onTapGesture { focused = true }

                if let errorMessage = vm.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 4)
                }
            }

            Button {
                Task {
                    if let session = await vm.verifyCode(code, for: email) {
                        coordinator.session = session
                        onVerified()
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

            Group {
                if cooldown > 0 {
                    Text("Resend in \(cooldown)s")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.secondary)
                } else {
                    HStack(spacing: 4) {
                        Text("Didn't receive a code?")
                            .foregroundStyle(Color.secondary)

                        Button {
                            Task {
                                if await vm.sendCode(to: email) {
                                    cooldown = 60
                                }
                            }
                        } label: {
                            Text("Resend")
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.white)
                        }
                        .buttonStyle(.plain)
                    }
                    .font(.system(size: 14, weight: .medium))
                }
            }
            .padding(.top, -24)
        }
        .padding(.horizontal, 22)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task(id: cooldown) {
            guard cooldown > 0 else { return }
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            cooldown -= 1
        }
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
        EmailCodeView(email: "your@email.com", onVerified: {})
            .environment(AppCoordinator())
    }
}
