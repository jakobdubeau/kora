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
    @State private var activeCourse: Course? = nil
    
    @Query(sort: \Course.createdAt) private var courses: [Course] // sort by created date, make courses array
    @Environment(\.modelContext) private var context // insert/delete/update
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 16) {
                    VStack(alignment: .center, spacing: 16) {
                        Text(Date(), format: .dateTime.weekday().day().month())
                            .font(.headline.bold())
                        Text("\(formatTime(seconds: vm.totalTime))") // string interpolation
                            .font(.system(size: 48, weight: .semibold))
                            .monospacedDigit()
                            .padding(.bottom, 4)
                        if vm.currentBreakTime > 60 {
                            Text("[Break for \(formatTimeBreak(seconds: vm.currentBreakTime))]")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        else {
                            Text("")
                        }
                    }
                    .padding(.top, 24)
                    Divider()
                        .opacity(0.5)
                    
                    List {
                        Section {
                            ForEach(courses) { course in
                                CourseRow(
                                    course: course,
                                    isActive: vm.isRunning(course),
                                    time: vm.courseTime(for: course),
                                    onTap: {
                                        activeCourse = course
                                        vm.toggleCourse(course)
                                    }
                                )
                                .listRowSeparator(.hidden)
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
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .fullScreenCover(isPresented: $showAddCourse) {
                AddCourse()
            }
            
            if let course = activeCourse {
                SessionCover(
                    vm: vm,
                    course: course,
                    onDismiss: { activeCourse = nil })
                        .transition(.opacity)
                        .zIndex(1)
            }
        }
        .animation(.easeIn(duration: 0.3), value: activeCourse == nil)
        .onAppear {
            vm.saveSession(context: context) // closure (setup once), timer engine saves sessions, from launch, everytime timer engine calls stopRunningCourse, closure fires
            vm.setup(context: context)
        }
    }
}
#Preview {
    HomeView()
        .modelContainer(for: [Course.self, StudySession.self], inMemory: true)
}

