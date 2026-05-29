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
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                Rectangle()
                    .foregroundStyle(Color(.separator).opacity(0.5))
                    .frame(height: 0.5)
    
                HStack {
                    Button {
                        withAnimation(.smooth(duration: 0.2)) {
                            selectedTab = .home
                        }
                    } label: {
                        Image(systemName: "house.fill")
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(selectedTab == .home ? Color.primary.opacity(0.8) : Color.secondary)
                    .frame(maxWidth: .infinity)
                    
                    Button {
                        withAnimation(.smooth(duration: 0.2)) {
                            selectedTab = .groups
                        }
                    } label: {
                        Image(systemName: "person.3.fill")
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(selectedTab == .groups ? Color.primary.opacity(0.8) : Color.secondary)
                    .frame(maxWidth: .infinity)
                    
                    Button {
                        withAnimation(.smooth(duration: 0.2)) {
                            selectedTab = .profile
                        }
                    } label: {
                        Image(systemName: "person.crop.circle.fill")
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(selectedTab == .profile ? Color.primary.opacity(0.8) : Color.secondary)
                    .frame(maxWidth: .infinity)
                    
                }
                .padding(.top, 19)
                .background(Color.secondary.opacity(0.05))
            }
        }
    }
}
