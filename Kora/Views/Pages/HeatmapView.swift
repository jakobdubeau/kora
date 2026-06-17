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
    @State private var daySelected: Bool = false
    @State private var dayTransition: Double = 0
    @State private var isAnimating: Bool = false
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            VStack(spacing: 16) {
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
                    
                    HeatmapGrid(dailyTotals: vm.dailyTotals, onTap: { day in if day != selectedDay { if !daySelected {
                        guard !isAnimating else { return }
                        daySelected = true
                        withAnimation(.spring(duration: 0.3)) { selectedDay = day }
                    } else {
                        withAnimation(.smooth(duration: 0.2)) { dayTransition = 1 }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { selectedDay = day
                            withAnimation(.smooth(duration: 0.2)) {
                                dayTransition = 0
                            }
                        }
                    }}}, month: selectedMonth)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 42)
            }
            .fixedSize(horizontal: false, vertical: true)
            .contentShape(Rectangle())
            .onTapGesture {
                isAnimating = true
                withAnimation(.spring(duration: 0.3)) {
                    selectedDay = nil
                }
                daySelected = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { isAnimating = false }
            }
            
            ZStack {
                if let day = selectedDay {
                    DailyTimeline(sessions: vm.sessions(for: day), date: day)
                        .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .bottom)), removal: .opacity.combined(with: .move(edge: .bottom))))
                }
                Color.black
                    .opacity(dayTransition)
                    .allowsHitTesting(false)
            }
            Spacer()
        }
        .onAppear {
            vm.setup(context: context, selectedMonth: selectedMonth)
        }
        .onChange(of: selectedMonth) {
            isAnimating = true
            vm.setup(context: context, selectedMonth: selectedMonth)
            withAnimation(.spring(duration: 0.3)) {
                selectedDay = nil
            }
            daySelected = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { isAnimating = false }
        }
        .padding(.top, 24)
    }
}

#Preview {
    HeatmapView()
        .modelContainer(for: [Course.self, StudySession.self], inMemory: true)
}
