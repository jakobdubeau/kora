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
                            withAnimation(.smooth(duration: 0.2)) {
                                tabTransition = 1
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                selectedTab = .home
                                withAnimation(.smooth(duration: 0.2)) {
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
                        .foregroundStyle(selectedTab == .home ? Color.primary.opacity(0.8) : Color.secondary)
                        
                        Button {
                            withAnimation(.smooth(duration: 0.2)) {
                                tabTransition = 1
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                selectedTab = .groups
                                withAnimation(.smooth(duration: 0.2)) {
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
                        .foregroundStyle(selectedTab == .groups ? Color.primary.opacity(0.8) : Color.secondary)
                        
                        Button {
                            withAnimation(.smooth(duration: 0.2)) {
                                tabTransition = 1
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                selectedTab = .profile
                                withAnimation(.smooth(duration: 0.2)) {
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
                        .foregroundStyle(selectedTab == .profile ? Color.primary.opacity(0.8) : Color.secondary)
                        
                    }
                    .padding(.top)
                    .padding(.bottom, 8)
                    .background(Color(hex: "#090909"))
                }
            }
        }
    }
}
