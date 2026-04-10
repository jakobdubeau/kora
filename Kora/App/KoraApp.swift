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
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: [Course.self, StudySession.self])
    }
}
