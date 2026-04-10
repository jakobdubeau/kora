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
    
    let course: Course
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            Group {
                if focusMode {
                    ZStack {
                        Color.black.ignoresSafeArea()
                        Text(formatTime(seconds: vm.timer.currentSessionTime))
                            .font(.system(size: 96, weight: .semibold))
                            .foregroundStyle(.white)
                            .monospacedDigit()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            focusMode = false
                        }
                    }
                    .transition(.opacity)
                } else {
                    VStack {
                        HStack {
                            HStack {
                                Text(course.name)
                                Text("[\(formatTime(seconds: vm.courseTime(for: course))) ]").monospacedDigit()
                            }
                            .font(.body)
                            Spacer()
                            Button {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    focusMode = true
                                }
                            } label: {
                                Image(systemName: "viewfinder")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                            .font(.system(size: 22))
                        }
                        .padding(.leading)
                        .padding(.trailing, 20)
                        .padding(.top, 8)
                        
                        HStack {
                            Text(formatTime(seconds: vm.timer.currentSessionTime))
                                .font(.system(size: 48, weight: .semibold))
                                .monospacedDigit()
                            Button {
                                vm.toggleCourse(course)
                                onDismiss()
                            } label: {
                                Image(systemName: "pause.circle.fill")
                                    .foregroundStyle(
                                        course.colour != nil ? Color(hex: course.colour!) : Color.secondary
                                    )
                                    .font(.system(size: 32))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.top, 36)
                        .padding(.bottom, 56)
                        
                        SessionGroup()
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 8)
                    .transition(.opacity)
                }
            }
            .statusBarHidden(focusMode)
        }
    }
}
