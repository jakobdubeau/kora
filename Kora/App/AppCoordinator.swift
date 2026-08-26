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
    var session: Session?
    var profile: UserProfile?
    var isGuest: Bool

    // user defaults is built in storage for small user device preferences
    init() {
        isGuest = UserDefaults.standard.bool(forKey: Self.guestKey)
    }

    func continueAsGuest() {
        UserDefaults.standard.set(true, forKey: Self.guestKey)
        isGuest = true
        state = .main
    }
}
