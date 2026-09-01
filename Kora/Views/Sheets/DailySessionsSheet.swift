//
//  DailySessionsSheet.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-06-24.
//

import SwiftUI
import SwiftData

struct DailySessionsSheet: View {
    @Bindable var vm: HeatmapViewModel
    
    @Environment(\.modelContext) private var context
    @Environment(AppCoordinator.self) private var coordinator
    
    let date: Date
    let onDismiss: () -> Void
    let onSessionDeleted: () -> Void

    @State private var ellipsisAnchors: [UUID: CGPoint] = [:]
    @State private var sessionMenu: SessionBlock?
    @State private var isDismissingMenu: Bool = false
    @State private var menuAnchor: CGPoint = .zero
    @State private var menuToken: Int = 0
    @State private var closingToken: Int = 0
    @State private var editingSession: SessionBlock?

    enum TimeBlock: Identifiable {
        case session(SessionBlock)
        case empty(start: Date, duration: TimeInterval)

        var id: Date {
            switch self {
            case .session(let session): return session.start
            case .empty(let start, _): return start
            }
        }
    }
    
    var blocks: [TimeBlock] {
        var res: [TimeBlock] = []
        
        let studyDate = Calendar.current.studyDayStart(for: date)

        let sessions = vm.sessions(for: Calendar.current.startOfDay(for: studyDate))
            .filter { $0.duration >= 1 }
            .sorted { $0.start < $1.start }

        let dayStart = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: studyDate)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: studyDate)!
        let dayEnd = Calendar.current.date(bySettingHour: 4, minute: 59, second: 59, of: tomorrow)
        
        var cursor = dayStart
        
        for session in sessions {
            if let cursor, session.start > cursor {
                res.append(.empty(start: cursor, duration: session.start.timeIntervalSince(cursor)))
            }
            res.append(.session(session))
            cursor = session.start.addingTimeInterval(session.duration)
        }
        
        if let cursor, let dayEnd, cursor < dayEnd {
            res.append(.empty(start: cursor, duration: dayEnd.timeIntervalSince(cursor)))
        }

        return res
    }
    
    // where default scroll should rest, between 0-1
    var lastSessionAnchor: UnitPoint {
        let heights = blocks.map { block -> CGFloat in
            switch block {
            case .empty(_, let duration): return max((duration / 3600) * 48, 24)
            case .session(let session): return max((session.duration / 3600) * 48, 48)
            }
        }
        let spacing: CGFloat = 10
        let total = heights.reduce(0, +) + spacing * CGFloat(max(heights.count - 1, 0))
        guard let last = blocks.lastIndex(where: { if case .session = $0 { return true } else { return false } }) else {
            return .top
        }
        let before = heights[..<last].reduce(0, +) + spacing * CGFloat(last)
        let center = before + heights[last] / 2
        return UnitPoint(x: 0.5, y: min((total > 0 ? center / total : 0.5) + 0.1, 1))
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.plain)
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("View Sessions")
                    .font(.headline.bold())
                
                Spacer()
                
                Button {
                    
                } label: {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.plain)
                .font(.system(size: 19, weight: .medium))
                .opacity(0)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 22)
            
            Rectangle()
                .foregroundStyle(Color(.separator).opacity(0.5))
                .frame(height: 0.5)
            
            ScrollView {
                HStack {
                    VStack(spacing: 10) {
                        ForEach(blocks) { block in
                            
                            switch block {
                            case .empty(let start, let duration):
                                let blankHeight = (duration / 3600) * 48
                                
                                Text(start.formatted(.dateTime.hour().minute()))
                                    .frame(height: max(blankHeight, 24), alignment: .topLeading)
                                    .font(.system(size: 9, weight: .regular))
                                    .foregroundStyle(Color(.separator))
                                    .transition(.opacity)
                                
                            case .session(let session):
                                let sessionHeight = (session.duration / 3600) * 48
                                
                                Text(session.start.formatted(.dateTime.hour().minute()))
                                    .frame(height: max(sessionHeight, 48), alignment: .topLeading)
                                    .font(.system(size: 9, weight: .regular))
                                    .foregroundStyle(.secondary)
                                    .transition(.opacity)
                            }
                        }
                        // this is the bottom time marker
                        Text("4:59 AM")
                            .frame(alignment: .topLeading)
                            .font(.system(size: 9, weight: .regular))
                            .foregroundStyle(Color(.separator))
                            .padding(.top, -24)
                            .padding(.bottom, 0)
                    }
                    .padding(.top, 6)
                    
                    VStack(spacing: 10) {
                        ForEach(blocks) { block in
                            
                            switch block {
                            case .empty(_, let duration):
                                let blankHeight = (duration / 3600) * 48
                                
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemBackground))
                                    .stroke(Color(.separator).opacity(0.5), lineWidth: 0.5)
                                    .overlay(Text("+ \(formatTimeBreak(seconds: duration))").frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading).padding(.horizontal, 12).padding(.vertical, 8).font(.system(size: 12, weight: .regular)).foregroundStyle(Color(.separator)))
                                    .frame(height: max(blankHeight, 24))
                                    .transition(.opacity)
                                
                            case .session(let session):
                                let sessionHeight = (session.duration / 3600) * 48
                                
                                HStack(spacing: 8) {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color(hex: session.colour ?? "#FFFFFF"))
                                        .frame(width: 8, height: max(sessionHeight - 16, 32))
                                        .padding(.leading, 8)
                                    
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text(session.name)
                                            .font(.system(size: 14, weight: .regular))
                                        Text(formatTimeBreak(seconds: session.duration))
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                    }
                                    .padding(.top, 7)
                                    Spacer()
                                    
                                    Button {
                                        menuAnchor = ellipsisAnchors[session.id] ?? .zero
                                        menuToken += 1
                                        isDismissingMenu = false
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                                            sessionMenu = session
                                        }
                                    } label: {
                                        Image(systemName: "ellipsis")
                                            .font(.system(size: 18, weight: .regular))
                                            .foregroundStyle(.white)
                                            .rotationEffect(.degrees(90))
                                            .frame(width: 32, height: 32, alignment: .trailing)
                                            .padding(.leading, -14)
                                            .padding(.trailing, 4)
                                    }
                                    .onGeometryChange(for: CGPoint.self) { geo in
                                        CGPoint(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
                                    } action: { point in
                                        ellipsisAnchors[session.id] = point
                                    }
                                    .frame(maxHeight: .infinity, alignment: .top)
                                    .padding(.top, 6)
                                }
                                .frame(height: max(sessionHeight, 48))
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color(hex: "#090909")).stroke(Color(.separator).opacity(0.5), lineWidth: (sessionMenu?.id == session.id && !isDismissingMenu) ? 2 : 0.5))
                                .transition(.opacity)
                            }
                        }
                    }
                    .padding(.trailing, 1)
                    .padding(.top, -9)
                }
                .padding(.top, 8)
            }
            .padding(.trailing, 12)
            .padding(.leading, 6)
            .scrollIndicators(.hidden)
            .defaultScrollAnchor(lastSessionAnchor)
        }
        .blur(radius: editingSession != nil ? 8 : 0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        // MARK: - Session Context Menu (Edit / Delete)
        .overlay {
            if sessionMenu != nil || isDismissingMenu {
                ZStack {
                    if sessionMenu != nil {
                        Color.clear
                            .contentShape(Rectangle())
                            .ignoresSafeArea()
                            .onTapGesture {
                                closingToken = menuToken
                                isDismissingMenu = true
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) { sessionMenu = nil }
                            }
                    }

                    EditDeleteButton(
                        onEdit: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                editingSession = sessionMenu
                            }
                            closingToken = menuToken
                            isDismissingMenu = true
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) { sessionMenu = nil }
                        },
                        onDelete: {
                            if let block = sessionMenu {
                                deleteSession(block)
                            }
                            closingToken = menuToken
                            isDismissingMenu = true
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) { sessionMenu = nil }
                        },
                        isDismissing: $isDismissingMenu,
                        onDismissComplete: {
                            if menuToken == closingToken {
                                isDismissingMenu = false
                            }
                        }
                    )
                    .id(menuToken)
                    .position(x: menuAnchor.x - 35, y: menuAnchor.y - 123)
                }
            }
        }
        // MARK: - Edit Session
        .overlay {
            if let session = editingSession {
                let limits = bounds(for: session)

                ZStack {
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) { editingSession = nil }
                        }

                    EditSession(
                        lowerBound: limits.lower,
                        upperBound: limits.upper,
                        initialStart: session.start,
                        initialEnd: session.start.addingTimeInterval(session.duration),
                        onCancel: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) { editingSession = nil }
                        },
                        onSave: { start, end in
                            updateSession(session, start: start, end: end)
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) { editingSession = nil }
                        }
                    )
                    .transition(.opacity)
                }
            }
        }
    }
    
    private func bounds(for block: SessionBlock) -> (lower: Date, upper: Date) {
        let studyDate = Calendar.current.studyDayStart(for: date)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: studyDate)!
        let dayStart = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: studyDate)!
        let dayEnd = Calendar.current.date(bySettingHour: 4, minute: 59, second: 59, of: tomorrow)!

        let others = vm.sessions(for: Calendar.current.startOfDay(for: studyDate))
            .filter { $0.duration >= 1 && $0.id != block.id }
            .sorted { $0.start < $1.start }

        let lower = others.last { $0.start < block.start }
            .map { $0.start.addingTimeInterval($0.duration) } ?? dayStart
        let upper = others.first { $0.start > block.start }?.start ?? dayEnd

        return (lower, upper)
    }

    private func updateSession(_ block: SessionBlock, start: Date, end: Date) {
        let id = block.id
        let descriptor = FetchDescriptor<StudySession>(predicate: #Predicate { $0.id == id })
        if let session = try? context.fetch(descriptor).first {
            session.start = start
            session.end = end
            withAnimation(.easeInOut(duration: 0.25)) {
                vm.setup(context: context, selectedMonth: date, userId: coordinator.userId)
            }
            onSessionDeleted()
        }
    }

    private func deleteSession(_ block: SessionBlock) {
        let id = block.id
        let descriptor = FetchDescriptor<StudySession>(predicate: #Predicate { $0.id == id })
        if let session = try? context.fetch(descriptor).first {
            context.delete(session)
            withAnimation(.easeInOut(duration: 0.25)) {
                vm.setup(context: context, selectedMonth: date, userId: coordinator.userId)
            }
            onSessionDeleted()
        }
    }
}
