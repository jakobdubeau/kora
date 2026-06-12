//
//  HeatmapGrid.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

import SwiftUI
import SwiftData

struct HeatmapGrid: View {
    
    let dailyTotals: [Date: TimeInterval]
    let onTap: (Date) -> Void
    
    var days: [Date?] {
        // first day of current month
        let start = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date.now))!
        // gets all day numbers in current month
        let range = Calendar.current.range(of: .day, in: .month, for: Date.now)!
        
        // gets weekday of first day
        let firstDay = Calendar.current.component(.weekday, from: start)
        // converts weekday into how many blank cells appear before day 1 of month
        let offset = (firstDay + 5) % 7
        
        // blank cells before first day of month
        let overlap = Array(repeating: nil as Date?, count: offset)
        
        // turns day numbers into dates
        let dates = range.map { day in
            Calendar.current.date(byAdding: .day, value: day - 1, to: start)
        }
        return overlap + dates
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
            ForEach(days.indices, id: \.self) { index in
                if let day = days[index] {
                    let colors = ["#090909", "#1D1D1D", "#2E2E2E", "#474747", "#6B6B6B", "#9D9D9D", "#FFFFFF"]
                    let colorIndex = [1, 2, 3, 4, 6, 8].filter { (dailyTotals[day] ?? 0) / 3600 >= $0 }.count
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: colors[colorIndex]))
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(.separator).opacity(0.5), lineWidth: 0.5))
                        .frame(height: 45)
                        .onTapGesture { onTap(day) }
                } else {
                    Color.clear.frame(height: 45)
                }
            }
        }
    }
}
