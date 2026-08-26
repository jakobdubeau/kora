//
//  KoraApp.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

import SwiftUI
import SwiftData

@main
struct KoraApp: App {
    @UIApplicationDelegateAdaptor(KoraAppDelegate.self) var appDelegate
    
    @State private var coordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            
            Group {
                switch coordinator.state {
                case .splash:
                    SplashView()
                case .login:
                    LoginView()
                case .onboarding:
                    OnboardingView()
                case .main:
                    TabsView()
                }
            }
            .environment(coordinator)
        }
        .modelContainer(for: [Course.self, StudySession.self])
    }
}
