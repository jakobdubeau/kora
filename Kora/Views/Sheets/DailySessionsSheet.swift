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
    
    let date: Date
    let onDismiss: () -> Void
    
    enum TimeBlock {
        case session(SessionBlock)
        case empty(start: Date, duration: TimeInterval)
    }
    
    var blocks: [TimeBlock] {
        var res: [TimeBlock] = []
        
        let sessions = vm.sessions(for: Calendar.current.startOfDay(for: date))
            .filter { $0.duration >= 1 }
            .sorted { $0.start < $1.start }
        
        let dayStart = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: date)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        let dayEnd = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: tomorrow)
        
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
                
                Text("Edit Sessions")
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
                        ForEach(blocks.indices, id: \.self) { index in
                            let block = blocks[index]
                            
                            switch block {
                            case .empty(let start, let duration):
                                let blankHeight = (duration / 3600) * 48
                                
                                Text(start.formatted(.dateTime.hour().minute()))
                                    .frame(height: max(blankHeight, 24), alignment: .topLeading)
                                    .font(.system(size: 9, weight: .regular))
                                    .foregroundStyle(Color(.separator))
                                
                            case .session(let session):
                                let sessionHeight = (session.duration / 3600) * 48
                                
                                Text(session.start.formatted(.dateTime.hour().minute()))
                                    .frame(height: max(sessionHeight, 48), alignment: .topLeading)
                                    .font(.system(size: 9, weight: .regular))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        // this is the bottom time marker
                        Text("5:00 AM")
                            .frame(alignment: .topLeading)
                            .font(.system(size: 9, weight: .regular))
                            .foregroundStyle(Color(.separator))
                            .padding(.top, -24)
                            .padding(.bottom, 0)
                    }
                    .padding(.top, 6)
                    
                    VStack(spacing: 10) {
                        ForEach(blocks.indices, id: \.self) { index in
                            let block = blocks[index]
                            
                            switch block {
                            case .empty(_, let duration):
                                let blankHeight = (duration / 3600) * 48
                                
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemBackground))
                                    .stroke(Color(.separator).opacity(0.5), lineWidth: 0.5)
                                    .overlay(Text("+ \(formatTimeBreak(seconds: duration))").frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading).padding(.horizontal, 12).padding(.vertical, 8).font(.system(size: 12, weight: .regular)).foregroundStyle(Color(.separator)))
                                    .frame(height: max(blankHeight, 24))
                                    .id(index)
                                
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
                                }
                                .frame(height: max(sessionHeight, 48))
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color(hex: "#090909")).stroke(Color(.separator).opacity(0.5), lineWidth: 0.5))
                                .id(index)
                            }
                        }
                    }
                    .padding(.top, -9)
                }
                .padding(.top, 8)
            }
            .padding(.trailing, 12)
            .padding(.leading, 6)
            .scrollIndicators(.hidden)
            .defaultScrollAnchor(lastSessionAnchor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
