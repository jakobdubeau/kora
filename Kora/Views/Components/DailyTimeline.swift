//
//  DailyTimeline.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-06-15.
//

import SwiftUI
import SwiftData

struct DailyTimeline: View {
    
    let sessions: [SessionBlock]
    let date: Date
    let hours = Array(4...29)
    
    var body: some View {
        VStack {
            Text(date, format: .dateTime.weekday().day().month())
                .font(.headline.bold())
                .multilineTextAlignment(.leading)
            
            VStack(spacing: 0) {
                ForEach(hours, id: \.self) { hour in
                    HStack {
                        Text(formatHour(hour: hour))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color(.separator))
                            .fontDesign(.monospaced)
                    }
                }
            }
        }
    }
}
