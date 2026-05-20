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
    @State private var orderedCourses: [Course] = []
    @Environment(\.modelContext) private var context // insert/delete/update
    
    let rowHeight: CGFloat = 64

    let asteriskColor: Color = {
        let allShades = Color.palettes
            .filter { $0.name != "grey" } // $0 means the current element being filtered
            .flatMap { $0.shades } // flatten all shades into an array
        return Color(hex: allShades.randomElement() ?? "#FFFFFF")
    }()

    let isGolden: Bool = Int.random(in: 0..<100) == 0
    @State private var shimmerRotation: Double = 0
    
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
                    .padding(.bottom, 26)
                    Divider()
                        .opacity(0.5)
                    
                    ScrollView {
                        ReorderableList(orderedCourses, rowHeight: rowHeight, onMove: { from, to in
                            orderedCourses.move(fromOffsets: IndexSet(integer: from), toOffset: (to > from) ? to + 1 : to)
                            for (index, course) in orderedCourses.enumerated() {
                                course.sortOrder = index
                            }
                        }) { course, _ in
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
                        }
                        
                        HStack {
                            Button {
                                showAddCourse = true
                            } label: {
                                HStack(spacing: 2) {
                                    Image("KoraAssetBoldSVG")
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundStyle(
                                            isGolden
                                                ? AnyShapeStyle(AngularGradient(
                                                    colors: [
                                                        Color(hex: "#A47711"),
                                                        Color(hex: "#D4A017"),
                                                        Color(hex: "#E3C95F"),
                                                        Color(hex: "#D4A017"),
                                                        Color(hex: "#A47711"),
                                                        Color(hex: "#D4A017"),
                                                        Color(hex: "#E3C95F"),
                                                        Color(hex: "#D4A017"),
                                                        Color(hex: "#A47711"),
                                                    ],
                                                    center: .center,
                                                    angle: .degrees(shimmerRotation)
                                                ))
                                                : AnyShapeStyle(asteriskColor)
                                        )
                                    Text("Add")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .padding(.leading, 6)
                                .padding(.trailing, 10)
                                .padding(.vertical, 5)
                                .background(Color(.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 32)
                                        .stroke(Color(.separator).opacity(0.5), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 4)
                            
                            Spacer()
                        }
                        .padding(.leading, 10)
                    }
                    .scrollBounceBehavior(.basedOnSize)
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
            orderedCourses = courses
            if isGolden {
                withAnimation(.linear(duration: 7).repeatForever(autoreverses: false)) {
                    shimmerRotation = 360
                }
            }
        }
        .onChange(of: courses) { _, newValue in
            if orderedCourses.count != newValue.count {
                orderedCourses = newValue
            }
        }
    }
}
#Preview {
    HomeView()
        .modelContainer(for: [Course.self, StudySession.self], inMemory: true)
}

