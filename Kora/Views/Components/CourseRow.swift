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
    let onEdit: () -> Void
    let onDelete: () -> Void
    
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
            .padding(.leading, 8)
            
            Text(course.name)
            
            Spacer()
            
            Text(formatTime(seconds: time))
                .monospacedDigit()
            
            Menu {
                Button("Edit") { onEdit() }
                Button("Delete", role: .destructive) { onDelete() }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(90))
                    .frame(width: 32, height: 32, alignment: .trailing)
                    .padding(.leading, -14)
                    .padding(.trailing, 4)
            }
            .contentShape(Rectangle())
            .dragHandle(id: course.id)
        }
        .frame(maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)))
    }
}
