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
    @State private var heatmapVM = HeatmapViewModel()
    @State private var showAddCourse: Bool = false
    @State private var showDailySessions: Bool = false
    @State private var activeCourse: Course? = nil
    @State private var courseMenu: Course? = nil
    @State private var editingCourse: Course? = nil
    @State private var isDismissingMenu: Bool = false
    @State private var menuAnchor: CGPoint = .zero
    @State private var menuToken: Int = 0
    @State private var closingToken: Int = 0
    @State private var rowDragging: Bool = false
    @State private var blackScreen: Double = 0
    
    @Binding var showTabs: Bool
    
    @Query private var courses: [Course]
    @State private var orderedCourses: [Course] = []
    @Environment(\.modelContext) private var context // insert/delete/update
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.scenePhase) private var scenePhase
    
    let rowHeight: CGFloat = 64

    init(showTabs: Binding<Bool>, userId: UUID?) {
        _showTabs = showTabs
        _courses = Query(
            filter: #Predicate<Course> { $0.userId == userId },
            sort: \Course.sortOrder
        )
    }

    private static let asteriskColor: Color = {
        let allShades = Color.palettes
            .filter { $0.name != "grey" } // $0 means the current element being filtered
            .flatMap { $0.shades } // flatten all shades into an array
        return Color(hex: allShades.randomElement() ?? "#FFFFFF")
    }()

    private static let isGolden: Bool = Int.random(in: 0..<100) == 0
    @State private var shimmerRotation: Double = 0
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 0) {
                    // MARK: - Date & Total Time
                    VStack(alignment: .center, spacing: 16) {
                        Text(Calendar.current.studyDayStart(for: Date.now), format: .dateTime.weekday().day().month())
                            .font(.headline.bold())
                            .padding(.bottom, -2)
                        Text("\(formatTime(seconds: vm.totalTime))") // string interpolation
                            .font(.system(size: 48, weight: .semibold))
                            .monospacedDigit()
                            .onTapGesture {
                                withAnimation(.easeOut(duration: 0.1)) {
                                    blackScreen = 1
                                    showTabs = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    heatmapVM.setup(context: context, selectedMonth: Date.now, userId: coordinator.userId)
                                    showDailySessions = true
                                    withAnimation(.easeOut(duration: 0.1)) {
                                        blackScreen = 0
                                    }
                                }

                            }
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
                    .padding(.bottom, 30)
                    .blur(radius: (courseMenu != nil && !isDismissingMenu) ? 8 : 0)
                    Rectangle()
                        .foregroundStyle(Color(.separator).opacity(0.5))
                        .frame(height: 0.5)
                        .blur(radius: (courseMenu != nil && !isDismissingMenu) ? 8 : 0)
                    
                    // MARK: - Course Rows
                    ScrollView {
                        ReorderableList(orderedCourses, rowHeight: rowHeight, onMove: { from, to in
                            orderedCourses.move(fromOffsets: IndexSet(integer: from), toOffset: (to > from) ? to + 1 : to)
                            for (index, course) in orderedCourses.enumerated() {
                                course.sortOrder = index
                            }
                        }) { course, isDragging in
                            CourseRow(
                                course: course,
                                isDragging: isDragging,
                                isFocused: courseMenu?.id == course.id && !isDismissingMenu,
                                isActive: vm.isRunning(course),
                                time: vm.courseTime(for: course),
                                onTap: {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        blackScreen = 1
                                        showTabs = false
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        activeCourse = course
                                        vm.toggleCourse(course)
                                        withAnimation(.easeOut(duration: 0.3)) {
                                            blackScreen = 0
                                        }
                                    }
                                },
                                onMenu: { anchor in
                                    menuAnchor = anchor
                                    menuToken += 1
                                    isDismissingMenu = false
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                                        courseMenu = course
                                    }
                                }
                            )
                            .blur(radius: (courseMenu != nil && courseMenu?.id != course.id && !isDismissingMenu) ? 8 : 0)
                            .clipped()
                            .onChange(of: isDragging) { _, dragging in
                                if dragging {
                                    rowDragging = true
                                } else {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        rowDragging = false
                                    }
                                }
                            }
                        }
                        
                        // MARK: - Add Course Button
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
                                            Self.isGolden
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
                                                : AnyShapeStyle(Self.asteriskColor)
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
                            .padding(.top, 6)
                            
                            Spacer()
                        }
                        .padding(.leading, 10)
                        .padding(.bottom, 72)
                        .blur(radius: (courseMenu != nil && !isDismissingMenu) ? 8 : 0)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .scrollIndicators(.hidden)
                    .scrollDisabled(courseMenu != nil)
                }
            }
            .fullScreenCover(isPresented: $showAddCourse) {
                AddCourse(userId: coordinator.userId)
            }
            .fullScreenCover(item: $editingCourse) { course in
                EditCourse(course: course)
            }
            
            // MARK: - Session Cover (Course Running)
            if let course = activeCourse {
                SessionCover(
                    vm: vm,
                    course: course,
                    onDismiss: {
                        vm.toggleCourse(course)
                        withAnimation(.easeOut(duration: 0.3)) {
                            blackScreen = 1
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            activeCourse = nil
                            withAnimation(.easeOut(duration: 0.3)) {
                                blackScreen = 0
                                showTabs = true
                            }
                        }
                    })
                    .zIndex(1)
            }
            
            // MARK: - Course Context Menu (Edit / Delete)
            if courseMenu != nil || isDismissingMenu {
                ZStack {
                    if courseMenu != nil {
                        Color.clear
                            .contentShape(Rectangle())
                            .ignoresSafeArea()
                            .allowsHitTesting(!rowDragging)
                            .onTapGesture {
                                closingToken = menuToken
                                isDismissingMenu = true
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) { courseMenu = nil }
                            }
                    }

                    EditDeleteButton(
                        onEdit: {
                            editingCourse = courseMenu
                            closingToken = menuToken
                            isDismissingMenu = true
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) { courseMenu = nil }
                        },
                        onDelete: {
                            if let course = courseMenu {
                                context.delete(course)
                                vm.setup(context: context, userId: coordinator.userId)
                            }
                            closingToken = menuToken
                            isDismissingMenu = true
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) { courseMenu = nil }
                        },
                        isDismissing: $isDismissingMenu,
                        onDismissComplete: {
                            if menuToken == closingToken {
                                isDismissingMenu = false
                            }
                        }
                    )
                    .id(menuToken)
                    .position(x: menuAnchor.x - 52, y: menuAnchor.y - 130)
                }
            }
            
            // MARK: - Daily Sessions Sheet
            if showDailySessions {
                DailySessionsSheet(
                    vm: heatmapVM,
                    date: Date.now,
                    onDismiss: {
                        withAnimation(.easeOut(duration: 0.1)) {
                            blackScreen = 1
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showDailySessions = false
                            showTabs = true
                            withAnimation(.easeOut(duration: 0.1)) {
                                blackScreen = 0
                            }
                        }
                    },
                    onSessionDeleted: {
                        vm.setup(context: context, userId: coordinator.userId)
                    })
                    .zIndex(1)
            }
            // MARK: - Black Screen Overlay
            Color.black
                .ignoresSafeArea()
                .opacity(blackScreen)
                .allowsHitTesting(false)
                .zIndex(2)
        }
        // MARK: - Lifecycle
        .onAppear {
            vm.saveSession(context: context, userId: coordinator.userId) // closure (setup once), timer engine saves sessions, from launch, everytime timer engine calls stopRunningCourse, closure fires
            vm.setup(context: context, userId: coordinator.userId)
            orderedCourses = courses
            if Self.isGolden {
                withAnimation(.linear(duration: 7).repeatForever(autoreverses: false)) {
                    shimmerRotation = 360
                }
            }
        }
        .onChange(of: courses) { _, newValue in
            if orderedCourses.count != newValue.count {
                withAnimation(.easeInOut(duration: 0.25)) {
                    orderedCourses = newValue
                }
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                vm.checkDayRollover()
            }
        }
    }
}
#Preview {
    HomeView(showTabs: .constant(true), userId: nil)
        .modelContainer(for: [Course.self, StudySession.self], inMemory: true)
        .environment(AppCoordinator())
}

