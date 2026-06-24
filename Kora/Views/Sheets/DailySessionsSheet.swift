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
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                
            }
            HStack {
                VStack {
                    
                }
                ScrollView {
                    
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
