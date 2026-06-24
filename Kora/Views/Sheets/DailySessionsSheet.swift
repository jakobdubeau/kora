//
//  DailySessionsSheet.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-06-24.
//

import SwiftUI
import SwiftData

struct DailySessionsSheet: View {
    @State private var vm = HeatmapViewModel()
    
    @Environment(\.modelContext) private var context
    
    let date: Date
    let onDismiss: () -> Void
    
    enum TimeBlock {
        case session(SessionBlock)
        case empty(start: Date, duration: TimeInterval)
    }
    
    var blocks: [TimeBlock] {
        var res: [TimeBlock] = []
        
        let sessions = vm.sessions(for: date).sorted { $0.start < $1.start }
        
        let dayStart = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: date)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        let dayEnd = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: tomorrow)
        
        var cursor = dayStart
        
        for session in sessions {
            if let cursor, session.start > cursor {
                res.append(.empty(start: cursor, duration: session.start.timeIntervalSince(cursor)))
                res.append(.session(session))
            }
            cursor = session.start.addingTimeInterval(session.duration)
        }
        
        if let cursor, let dayEnd, cursor < dayEnd {
            res.append(.empty(start: cursor, duration: dayEnd.timeIntervalSince(cursor)))
        }

        return res
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
            .padding(.horizontal, 32)
            .padding(.top, 22)
            
            HStack {
                VStack {
                    
                }
                ScrollView {
                    
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onAppear {
            vm.setup(context: context, selectedMonth: date)
        }
    }
}
