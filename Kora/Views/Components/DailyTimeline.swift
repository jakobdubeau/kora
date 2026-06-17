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
                ZStack(alignment: .top) {
                    VStack(spacing: 0) {
                        ForEach(hours, id: \.self) { hour in
                            HStack(alignment: .center, spacing: 8) {
                                Text(formatHour(hour: hour))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color(.separator))
                                    .fontDesign(.monospaced)
                                    .frame(width: 30, alignment: .leading)
                                
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
                    ForEach(sessions.indices, id: \.self) { index in
                        let session = sessions[index]
                        let hour = Calendar.current.component(.hour, from: session.start)
                        let minute = Calendar.current.component(.minute, from: session.start)
                        let startTime = (Double(hour - 5) + Double(minute) / 60.0) * 48 + 24
                        let sessionHeight = (session.duration / 3600) * 48
                        
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(hex: session.colour ?? "#FFFFFF"))
                                .frame(width: 8)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text(session.name)
                                    .font(.system(size: 12, weight: .regular))
                                Text(formatTimeBreak(seconds: session.duration))
                                    .font(.system(size: 10, weight: .regular))
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding(.top, 7)
                            .opacity(sessionHeight >= 24 ? 1 : 0)
                            Spacer()
                        }
                        .frame(height: sessionHeight)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color(.separator).opacity(0.5), lineWidth: 1))
                        .padding(.leading, 44)
                        .padding(.trailing, 16)
                        .padding(.top, startTime)
                    }
                }
                .frame(height: 1200)
            }
            .padding(.horizontal, 4)
            .scrollIndicators(.hidden)
        }
    }
}
