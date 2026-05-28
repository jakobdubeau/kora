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
        
        ZStack(alignment: .bottom) {
            switch selectedTab {
                
            case .home:
                HomeView()
                
            case .groups:
                HomeView()
                
            case .profile:
                HomeView()
            
            }
            HStack {
                Button {
                    withAnimation(.smooth(duration: 0.2)) {
                        selectedTab = .home
                    }
                } label: {
                    Image(systemName: "house.fill")
                }
                .buttonStyle(.plain)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                
                Button {

                } label: {
                    Image(systemName: "person.3.fill")
                }
                .buttonStyle(.plain)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                
                Button {

                } label: {
                    Image(systemName: "person.crop.circle.fill")
                }
                .buttonStyle(.plain)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.gray)
                .frame(maxWidth: .infinity)
                
            }
        }
    }
}
