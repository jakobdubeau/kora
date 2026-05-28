//
//  TabsView.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

import SwiftUI

struct TabsView: View {
    
    enum Tab {
        case home
        case groups
        case profile
    }
    
    @State private var selectedTab: Tab = .home
    
    var body: some View {
        
        ZStack {
            switch selectedTab {
                
            case .home:
                HomeView()
                
            case .groups:
                HomeView()
                
            case .profile:
                HomeView()
            
            }
            Text("bar")
        }
    }
}
