//
//  HeatmapView.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

import SwiftUI
import SwiftData

struct HeatmapView: View {
    @State private var vm = HeatmapViewModel()
    @State private var selectedDay: Date?
    @State private var selectedMonth: Date = Date()
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            HStack(spacing: 22) {
                Button {

                } label: {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.plain)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
                // use Color(.separator).opacity(0.5) for disabled (end)
                
                Text(Date(), format: .dateTime.month())
                    .font(.headline.bold())
                
                Button {

                } label: {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.plain)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
            }
            VStack {
                HStack(alignment: .center, spacing: 37) {
                    Text("M")
                    Text("T")
                    Text("W")
                    Text("T")
                    Text("F")
                    Text("S")
                    Text("S")
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(.separator))
                .fontDesign(.monospaced)
                
                HeatmapGrid(dailyTotals: vm.dailyTotals, onTap: {_ in})
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 42)
            
            Rectangle()
                .foregroundStyle(Color(.separator).opacity(0.5))
                .frame(height: 0.5)
            
            ScrollView {
                Text("blocks")
            }
            .opacity(selectedDay == nil ? 0 : 1)
        }
        .onAppear {
            vm.setup(context: context)
        }
        .padding(.top, 24)
    }
}

#Preview {
    HeatmapView()
        .modelContainer(for: [Course.self, StudySession.self], inMemory: true)
}
