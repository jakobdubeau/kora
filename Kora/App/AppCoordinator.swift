//
//  AppCoordinator.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-23.
//

import Foundation
import Observation
import Supabase

enum AppState {
    case splash
    case login
    case onboarding
    case main
}

@Observable
final class AppCoordinator {
    
    private static let guestKey = "hasSkippedLogin"
    
    var state: AppState = .splash
    var blackScreen: Double = 0
    var session: Session?
    var profile: UserProfile?
    private var hasSkippedLogin: Bool

    var isGuest: Bool {
        session == nil && hasSkippedLogin
    }

    var userId: UUID? {
        session?.user.id
    }

    // user defaults is built in storage for small user device preferences
    init() {
        hasSkippedLogin = UserDefaults.standard.bool(forKey: Self.guestKey)
    }

    func continueAsGuest() {
        UserDefaults.standard.set(true, forKey: Self.guestKey)
        hasSkippedLogin = true
        state = .main
    }

    func clearGuest() {
        UserDefaults.standard.removeObject(forKey: Self.guestKey)
        hasSkippedLogin = false
    }
}
