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
    @State private var selectedMonth: Date = Date.now
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            HStack(spacing: 22) {
                Button {
                    selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth)!
                } label: {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.plain)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
                .disabled(selectedMonth <= (vm.firstActiveMonth ?? selectedMonth))
                
                Text(selectedMonth, format: .dateTime.month())
                    .font(.headline.bold())
                    .frame(width: 54)
                
                Button {
                    selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth)!
                } label: {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.plain)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
                .disabled(Calendar.current.isDate(selectedMonth, equalTo: Date.now, toGranularity: .month))
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
                
                HeatmapGrid(dailyTotals: vm.dailyTotals, onTap: {day in selectedDay = day}, month: selectedMonth)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 42)
            
            if let day = selectedDay {
                DailyTimeline(sessions: vm.dailySessions[day] ?? [], date: day)
            }
            Spacer()
        }
        .onAppear {
            vm.setup(context: context, selectedMonth: selectedMonth)
        }
        .onChange(of: selectedMonth) {
            vm.setup(context: context, selectedMonth: selectedMonth)
            selectedDay = nil
        }
        .padding(.top, 24)
    }
}

#Preview {
    HeatmapView()
        .modelContainer(for: [Course.self, StudySession.self], inMemory: true)
}
