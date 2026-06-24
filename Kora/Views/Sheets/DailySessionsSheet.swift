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
    
    let sessions: [SessionBlock]
    let date: Date

    
    var body: some View {
        Text("DailySessionsSheet")
    }
}
