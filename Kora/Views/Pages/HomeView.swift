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
    @State private var showAddCourse = false
    
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
                    if vm.breakTime > 1000000000000 {
                        Text("[Break for \(formatTimeBreak(seconds: vm.breakTime))]")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 20)
                
                List {
                    Section {
                        ForEach(courses) { course in
                            CourseRow(
                                course: course,
                                isActive: vm.isRunning(course),
                                time: vm.courseTime(for: course),
                                onTap: {
                                    vm.toggleCourse(course)
                                }
                            )
                        }
                        .onDelete { indexSet in // index set is indices of rows user deletes
                            for index in indexSet {
                                context.delete(courses[index]) // deletes the actual course model
                            }
                        }
                    }
                    footer: {
                        Button("Add") {
                            showAddCourse = true
                        }
                        .foregroundStyle(.secondary)
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showAddCourse) {
            AddCourse()
        }
    }
}
#Preview {
    HomeView()
        .modelContainer(for: [Course.self], inMemory: true)
}

