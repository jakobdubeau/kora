//
//  CourseRow.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

import SwiftUI
import SwiftData

struct CourseRow: View {
    let course: Course
    let isActive: Bool
    let time: TimeInterval
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Button {
                onTap()
            } label: {
                Image(systemName: isActive ? "pause.circle.fill" : "play.circle.fill")
                    .foregroundStyle(
                        course.colour != nil ? Color(hex: course.colour!) : Color.secondary
                    )
                    .font(.system(size: 32))
            }
            .buttonStyle(.plain)
            
            Text(course.name)
            
            Spacer()
            
            Text(formatTime(seconds: time))
                .monospacedDigit()
        }
    }
}
