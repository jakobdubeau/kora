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
    @State private var blackScreen: Double = 0
    
    @Query(sort: \Course.sortOrder) private var courses: [Course]
    @Environment(\.modelContext) private var context // insert/delete/update
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 0) {
                    VStack(alignment: .center, spacing: 16) {
                        Text(Date(), format: .dateTime.weekday().day().month())
                            .font(.headline.bold())
                            .padding(.bottom, -2)
                        Text("\(formatTime(seconds: vm.totalTime))") // string interpolation
                            .font(.system(size: 48, weight: .semibold))
                            .monospacedDigit()
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
                    .padding(.bottom, 24)
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
                                        withAnimation(.easeOut(duration: 0.3)) {
                                            blackScreen = 1
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            activeCourse = course
                                            vm.toggleCourse(course)
                                            withAnimation(.easeOut(duration: 0.3)) {
                                                blackScreen = 0
                                            }
                                        }
                                    },
                                    onEdit: { },
                                    onDelete: { context.delete(course) }
                                )
                                .listRowSeparator(.hidden)
                            }
                            .onDelete { indexSet in // index set is indices of rows user deletes
                                for index in indexSet {
                                    context.delete(courses[index]) // deletes the actual course model
                                }
                            }
                            .onMove { from, to in   // from (index set) = which rows moved, = to (index) new index where it moved
                                var reordered = courses // make a copy so it's mutable
                                
                                // array gets copied, but the course objects inside are still references to the same models
                                // (editing a course edits the real stored object)
                                
                                reordered.move(fromOffsets: from, toOffset: to)
                                
                                // for in loops are vor logic, ForEach are for swiftui views
                                for (index, course) in reordered.enumerated() {
                                    course.sortOrder = index
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
                    .contentMargins(.top, 0, for: .scrollContent)
                    .padding(.bottom)
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
                    onDismiss: {
                        withAnimation(.easeOut(duration: 0.3)) {
                            blackScreen = 1
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            vm.toggleCourse(course)
                            activeCourse = nil
                            withAnimation(.easeOut(duration: 0.3)) {
                                blackScreen = 0
                            }
                        }
                    })
                    .zIndex(1)
            }

            Color.black
                .ignoresSafeArea()
                .opacity(blackScreen)
                .allowsHitTesting(false)
                .zIndex(2)
        }
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

