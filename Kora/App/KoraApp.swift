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

    private let authService = SupabaseAuthService()
    private let profileService = SupabaseProfileService()
    
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
            .onOpenURL { url in
                Task {
                    coordinator.session = try? await authService.session(from: url)

                    if let userId = coordinator.userId {
                        do {
                            coordinator.profile = try await profileService.fetchProfile(userId: userId)
                            coordinator.state = coordinator.profile == nil ? .onboarding : .main
                        } catch {
                            coordinator.state = .main
                        }
                    }
                }
            }
        }
        .modelContainer(for: [Course.self, StudySession.self])
    }
}
