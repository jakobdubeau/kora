//
//  HomeViewModel.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

// list of courses, totals, timers

import Foundation
import Observation
import SwiftData

@Observable
final class HomeViewModel {
    
    let timer = TimerEngine()

    private var lastLoadedDay = Calendar.current.studyDayStart(for: .now)
    private var rolloverTimer: Timer?
    
    var totalTime: TimeInterval { timer.totalTime }
    var breakTime: TimeInterval { timer.breakTime }
    var currentBreakTime: TimeInterval { timer.currentBreakTime }
    
    var onBreak: Bool { timer.runningCourse == nil }
    
    func isRunning(_ course: Course) -> Bool {
        timer.runningCourse == course.id
    }
    
    func courseTime(for course: Course) -> TimeInterval {
        timer.courseTime(for: course.id)
    }
    
    func toggleCourse(_ course: Course) {
        timer.toggleCourse(course.id)
    }
    
    func newDay() {
        timer.newDay()
    }

    func checkDayRollover() {
        let currentDay = Calendar.current.studyDayStart(for: .now)
        guard currentDay != lastLoadedDay else { return }

        timer.rollToNewDay(boundary: currentDay)
        lastLoadedDay = currentDay
        scheduleRollover()
    }

    private func scheduleRollover() {
        rolloverTimer?.invalidate()
        let nextBoundary = Calendar.current.date(byAdding: .day, value: 1, to: lastLoadedDay)!
        rolloverTimer = Timer.scheduledTimer(withTimeInterval: nextBoundary.timeIntervalSinceNow, repeats: false) { [weak self] _ in
            self?.checkDayRollover()
        }
    }
    
    func setup(context: ModelContext, userId: UUID?) {
        let todayStart = Calendar.current.studyDayStart(for: Date.now)
        let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: todayStart)!
        let lowerBound = Calendar.current.date(byAdding: .day, value: -1, to: todayStart)!

        let descriptor = FetchDescriptor<StudySession>(
            predicate: #Predicate { session in session.userId == userId && session.start >= lowerBound && session.start < dayEnd }
        )

        let courseDescriptor = FetchDescriptor<Course>(
            predicate: #Predicate { course in course.userId == userId }
        )
        let courseIds = Set(((try? context.fetch(courseDescriptor)) ?? []).map { $0.id })
        
        if let sessions = try? context.fetch(descriptor) {
            var totals: [UUID: TimeInterval] = [:]
            for session in sessions {
                guard let courseId = session.courseId, courseIds.contains(courseId) else { continue }
                let end = session.start.addingTimeInterval(session.duration)
                let contribution = min(end, dayEnd).timeIntervalSince(max(session.start, todayStart))
                guard contribution > 0 else { continue }
                totals[courseId, default: 0] += contribution.rounded(.down)
            }
            timer.loadCourseTimes(totals)
        }

        lastLoadedDay = todayStart
        scheduleRollover()
    }
    
    func saveSession(context: ModelContext, userId: UUID?) {
        timer.onSessionEnd = { courseId, startDate, endDate in
            let descriptor = FetchDescriptor<Course>(predicate: #Predicate { $0.id == courseId })
            let course = (try? context.fetch(descriptor))?.first

            let session = StudySession(courseId: courseId, start: startDate, end: endDate, isCompleted: true, courseName: course?.name, courseColour: course?.colour, userId: userId)
            
            context.insert(session)
        }
    }
}
