//
//  AppConfig.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-23.
//

import Foundation

enum AppConfig {
    static let supabaseURL = URL(string: Secrets.supabaseURL)!
    static let supabaseKey = Secrets.supabaseKey
    static let redirectURL = URL(string: "kora://auth-callback")!
}
