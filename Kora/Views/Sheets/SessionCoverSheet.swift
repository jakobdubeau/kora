//
//  SessionCoverSheet.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-04-10.
//

import SwiftUI

struct SessionCover: View {
    @Bindable var vm: HomeViewModel
    @State private var focusMode: Bool = false
    @State private var statusBarHidden: Bool = false
    
    let course: Course
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            Group {
                if focusMode {
                    GeometryReader { geo in
                        ZStack {
                            Color.black
                            Text(formatTime(seconds: vm.timer.currentSessionTime))
                                .font(.system(size: 128, weight: .semibold))
                                .foregroundStyle(.white)
                                .monospacedDigit()
                        }
                        .frame(width: geo.size.height, height: geo.size.width)
                        .rotationEffect(.degrees(90))
                        .frame(width: geo.size.width, height: geo.size.height)
                    }
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        statusBarHidden = false
                        withAnimation(.easeIn(duration: 0.2)) {
                            focusMode = false
                        }
                    }
                    .transition(.opacity)
                } else {
                    VStack(spacing: 8) {
                        HStack {
                            HStack {
                                Text(course.name)
                                Text("[\(formatTime(seconds: vm.courseTime(for: course)))]").monospacedDigit()
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.secondary)
                            Spacer()
                            Button {
                                statusBarHidden = true
                                withAnimation(.easeIn(duration: 0.2)) {
                                    focusMode = true
                                }
                            } label: {
                                Image(systemName: "viewfinder")
                            }
                            .buttonStyle(.plain)
                            .font(.system(size: 19, weight: .medium))
                            .foregroundStyle(.secondary)
                            .padding(.top, -4)
                        }
                        .padding(.leading)
                        .padding(.trailing, 20)
                        .padding(.top, 9)
                        
                        VStack(spacing: 8) {
                            Text(formatTime(seconds: vm.timer.currentSessionTime))
                                .font(.system(size: 48, weight: .semibold))
                                .monospacedDigit()
                            Button {
                                onDismiss()
                            } label: {
                                AnimatedKoraAsterisk(
                                    color: course.colour != nil ? Color(hex: course.colour!) : Color.secondary,
                                    size: 54
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 22)
                        
                        SessionGroup()
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 8)
                    .transition(.opacity)
                }
            }
        }
        .statusBarHidden(statusBarHidden)
    }
}
