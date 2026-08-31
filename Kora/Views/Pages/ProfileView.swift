//
//  ProfileView.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-08-24.
//

import SwiftUI

struct ProfileView: View {

    @Environment(AppCoordinator.self) private var coordinator

    private let authService = SupabaseAuthService()

    var body: some View {
        VStack(spacing: 16) {
            Text(coordinator.profile?.username ?? "Guest")
                .font(.system(size: 22, weight: .medium))

            Button {
                Task {
                    try? await authService.signOut()
                    coordinator.clearGuest()
                    coordinator.session = nil
                    coordinator.profile = nil
                    coordinator.state = .login
                }
            } label: {
                Text("Sign out")
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color(.separator).opacity(0.5), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ProfileView()
        .environment(AppCoordinator())
}
