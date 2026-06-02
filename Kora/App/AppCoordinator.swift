//
//  AppCoordinator.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-23.
//

import Observation

enum AppState {
    case splash
    case login
    case main
}

@Observable
final class AppCoordinator {
    
    var state: AppState = .splash
    
}
