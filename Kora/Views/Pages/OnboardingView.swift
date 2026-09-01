//
//  OnboardingView.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-08-25.
//

import SwiftUI

struct OnboardingView: View {

    @Environment(AppCoordinator.self) private var coordinator

    @State private var vm = OnboardingViewModel()

    private var messageColor: Color {
        switch vm.status {
        case .idle, .checking: Color.secondary
        case .invalid, .taken: Color.red
        case .available: Color.green
        }
    }

    var body: some View {
        VStack(spacing: 48) {
            VStack(spacing: 16) {
                Text("Welcome to Kora")
                    .font(.system(size: 22, weight: .medium))
                    .fontDesign(.monospaced)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Choose a username so your friends can find you.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.secondary)
                    .fontDesign(.monospaced)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom, -8)

            VStack(alignment: .leading, spacing: 12) {
                TextField("Username", text: $vm.username)
                    .font(.system(size: 18, weight: .regular))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(Color(hex: "#090909"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator).opacity(0.5), lineWidth: 0.5))

                Text(vm.errorMessage ?? vm.message)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(vm.errorMessage == nil ? messageColor : Color.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
            }

            Button {
                guard let userId = coordinator.userId else { return }

                Task {
                    if let profile = await vm.submit(userId: userId) {
                        coordinator.profile = profile
                        coordinator.state = .main
                    }
                }
            } label: {
                Text("Continue")
                    .font(.system(size: 18, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(vm.status == .available ? Color.white : Color(hex: "#090909"))
                    .foregroundStyle(vm.status == .available ? Color.black : Color(.separator))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator).opacity(0.5), lineWidth: 0.5))
                    .animation(.smooth(duration: 0.2), value: vm.status)
            }
            .buttonStyle(.plain)
            .disabled(vm.isSubmitting)
        }
        .padding(.horizontal, 22)
        .task(id: vm.username) {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await vm.checkAvailability()

            try? await Task.sleep(for: .milliseconds(700))
            guard !Task.isCancelled else { return }
            vm.tooShort()
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppCoordinator())
}
