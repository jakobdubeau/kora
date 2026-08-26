//
//  SplashView.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

import SwiftUI

struct SplashView: View {
    
    @Environment(AppCoordinator.self) private var coordinator
    private let authService = SupabaseAuthService()
    
    var body: some View {
        AnimatedKoraAsterisk(color: .primary, size: 172)
            .padding(.bottom, 52)
            .task {
                coordinator.session = await authService.restoreSession()
                
                if coordinator.session != nil {
                    coordinator.state = .onboarding
                } else if coordinator.isGuest {
                    coordinator.state = .main
                } else {
                    coordinator.state = .login
                }
            }
    }
}
