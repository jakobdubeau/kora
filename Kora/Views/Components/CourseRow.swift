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
    let isDragging: Bool
    let isActive: Bool
    let time: TimeInterval
    let onTap: () -> Void
    let onMenu: (CGPoint) -> Void

    @State private var ellipsisAnchor: CGPoint = .zero
    @State private var blockMenu: Bool = false

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
            
            Button {
                guard !blockMenu else { return }
                onMenu(ellipsisAnchor)
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
            .simultaneousGesture(
                DragGesture(minimumDistance: 4)
                    .onChanged { _ in blockMenu = true }
                    .onEnded { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            blockMenu = false
                        }
                    }
            )
            .dragHandle(id: course.id)
            .onGeometryChange(for: CGPoint.self) { geo in
                CGPoint(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
            } action: { point in
                ellipsisAnchor = point
            }
        }
        .frame(maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)))
        .overlay(isDragging ? RoundedRectangle(cornerRadius: 14).stroke(Color(.separator).opacity(0.5), lineWidth: 0.5)
                 : RoundedRectangle(cornerRadius: 14).stroke(Color(.separator).opacity(0), lineWidth: 0.5))
        .animation(.smooth(duration: 0.1), value: isDragging)
    }
}
