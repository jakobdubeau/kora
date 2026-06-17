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
    @State private var activeTab: Tab = .home
    @State private var showTabs: Bool = true
    @State private var tabTransition: Double = 0
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            switch selectedTab {
                
            case .home:
                HomeView(showTabs: $showTabs)
                
            case .groups:
                HeatmapView()
                
            case .profile:
                HomeView(showTabs: $showTabs)
                
            }
            
            Color.black
                .ignoresSafeArea()
                .opacity(tabTransition)
                .allowsHitTesting(false)
        }
        .safeAreaInset(edge: .bottom) {
            if showTabs {
                VStack(spacing: 0) {
                    Rectangle()
                        .foregroundStyle(Color(.separator).opacity(0.5))
                        .frame(height: 0.5)
                    
                    HStack {
                        Button {
                            activeTab = .home
                            withAnimation(.smooth(duration: 0.1)) {
                                tabTransition = 1
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                selectedTab = .home
                                withAnimation(.smooth(duration: 0.1)) {
                                    tabTransition = 0
                                }
                            }
                        } label: {
                            Image(systemName: "house.fill")
                                .frame(maxWidth: .infinity)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(activeTab == .home ? Color.primary.opacity(0.8) : Color.secondary)
                        .allowsHitTesting(activeTab != .home)
                        
                        Button {
                            activeTab = .groups
                            withAnimation(.smooth(duration: 0.1)) {
                                tabTransition = 1
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                selectedTab = .groups
                                withAnimation(.smooth(duration: 0.1)) {
                                    tabTransition = 0
                                }
                            }
                        } label: {
                            Image(systemName: "person.3.fill")
                                .frame(maxWidth: .infinity)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(activeTab == .groups ? Color.primary.opacity(0.8) : Color.secondary)
                        .allowsHitTesting(activeTab != .groups)
                        
                        Button {
                            activeTab = .profile
                            withAnimation(.smooth(duration: 0.1)) {
                                tabTransition = 1
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                selectedTab = .profile
                                withAnimation(.smooth(duration: 0.1)) {
                                    tabTransition = 0
                                }
                            }
                        } label: {
                            Image(systemName: "person.crop.circle.fill")
                                .frame(maxWidth: .infinity)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(activeTab == .profile ? Color.primary.opacity(0.8) : Color.secondary)
                        .allowsHitTesting(activeTab != .profile)
                        
                    }
                    .padding(.top)
                    .padding(.bottom, 8)
                    .background(Color(hex: "#090909"))
                }
            }
        }
    }
}
