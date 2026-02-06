//
//  HomeView.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var vm = HomeViewModel() // @state ensures viewmodel instance isn't lost after redraw
    
    @Query(sort: \Course.createdAt) private var courses: [Course] // sort by created date, make courses array
    @Environment(\.modelContext) private var context // insert/delete/update
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .center, spacing: 16) {
                    Text(Date(), format: .dateTime.weekday().day().month())
                        .font(.headline.bold())
                        .padding(.bottom, 12)
                    Text("\(formatTime(seconds: vm.totalTime))") // string interpolation
                        .font(.system(size: 48, weight: .semibold))
                        .monospacedDigit()
                    if vm.breakTime > 0 {
                        Text("[Break for \(formatTimeBreak(seconds: vm.breakTime))]")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.top, 20).frame(maxWidth: .infinity)
            }
            List(courses) { course in
                Text(course.name)
            }
        }
    }
}
#Preview {
    HomeView()
}

