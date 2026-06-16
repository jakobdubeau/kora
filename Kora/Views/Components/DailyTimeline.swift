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
    let hours = Array(5...29)
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(date, format: .dateTime.weekday().day().month())
                .font(.headline.bold())
            
            Rectangle()
                .foregroundStyle(Color(.separator).opacity(0.5))
                .frame(height: 0.5)
                .padding(.top, 16)
            
            ScrollView {
                ForEach(hours, id: \.self) { hour in
                    HStack(alignment: .center, spacing: 8) {
                        Text(formatHour(hour: hour))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color(.separator))
                            .fontDesign(.monospaced)
                            .frame(width: 32, alignment: .leading)
                        
                        GeometryReader { geo in
                            Path { path in
                                path.move(to: .zero)
                                path.addLine(to: CGPoint(x: geo.size.width, y: 0))
                            }
                            .stroke(Color(.separator).opacity(0.5), style: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                        }
                        .frame(height: 0.5)
                    }
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}
