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
        VStack {
            HStack {
                HStack {
                    Text(course.name)
                    Text("[\(formatTime(seconds: vm.courseTime(for: course))) ]").monospacedDigit()
                }
                .font(.body)
                .foregroundStyle(.secondary)
                Spacer()
                Button {
                    focusMode = true
                } label: {
                    Image(systemName: "viewfinder")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .font(.system(size: 20))
            }
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
            .padding(.top, 42)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .background(Color(.systemBackground))
    }
}
