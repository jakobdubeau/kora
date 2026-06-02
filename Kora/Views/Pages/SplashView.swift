//
//  SplashView.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

import SwiftUI

struct SplashView: View {
    
    @Environment(AppCoordinator.self) private var coordinator
    
    var body: some View {
        AnimatedKoraAsterisk(color: .primary, size: 172)
            .padding(.bottom, 52)
            .onAppear {
                coordinator.state = .login
            }
    }
}
