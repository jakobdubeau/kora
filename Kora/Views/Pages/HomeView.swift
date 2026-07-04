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
    @State private var isDismissingMenu: Bool = false
    @State private var menuAnchor: CGPoint = .zero
    @State private var menuToken: Int = 0
    @State private var closingToken: Int = 0
    @State private var rowDragging: Bool = false
    @State private var blackScreen: Double = 0
    
    @Binding var showTabs: Bool
    
    @Query(sort: \Course.sortOrder) private var courses: [Course]
    @State private var orderedCourses: [Course] = []
    @Environment(\.modelContext) private var context // insert/delete/update
    
    let rowHeight: CGFloat = 64

    @State private var asteriskColor: Color = {
        let allShades = Color.palettes
            .filter { $0.name != "grey" } // $0 means the current element being filtered
            .flatMap { $0.shades } // flatten all shades into an array
        return Color(hex: allShades.randomElement() ?? "#FFFFFF")
    }()

    @State private var isGolden: Bool = Int.random(in: 0..<100) == 0
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
                            .onTapGesture {
                                withAnimation(.easeOut(duration: 0.1)) {
                                    blackScreen = 1
                                    showTabs = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    heatmapVM.setup(context: context, selectedMonth: Date.now)
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
                        .padding(.bottom, 72)
                        .blur(radius: (courseMenu != nil && !isDismissingMenu) ? 8 : 0)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .scrollIndicators(.hidden)
                    .scrollDisabled(courseMenu != nil)
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
                        onEdit: {},
                        onDelete: {},
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
    HomeView(showTabs: .constant(true))
        .modelContainer(for: [Course.self, StudySession.self], inMemory: true)
}

