//
//  HeatmapMapper.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

import Foundation

// snapshot of session data for visual time block
struct SessionBlock {
    let duration: TimeInterval
    let start: Date
    let name: String
    let colour: String?
    let id: UUID
}

// get daily hours and sessions
struct HeatmapMapper {
    static func map(sessions: [StudySession], courses: [Course]) -> (dailyTotals: [Date: TimeInterval], dailySessions: [Date: [SessionBlock]]) {
        
        var dailyTotals: [Date: TimeInterval] = [:]
        var dailySessions: [Date: [SessionBlock]] = [:]
        
        var courseLookup: [UUID: Course] = [:]

        for course in courses {
            courseLookup[course.id] = course
        }
        
        for session in sessions {
            let sessionCourse = session.courseId.flatMap { courseLookup[$0] }
            let name = session.courseName ?? sessionCourse?.name ?? "Deleted course"
            let colour = session.courseColour ?? sessionCourse?.colour

            let end = session.start.addingTimeInterval(session.duration)
            let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.studyDayStart(for: session.start))!

            if end <= dayEnd {
                let sessionDay = Calendar.current.startOfDay(for: Calendar.current.studyDayStart(for: session.start))
                dailyTotals[sessionDay, default: 0] += session.duration.rounded(.down)
                let block = SessionBlock(duration: session.duration.rounded(.down), start: session.start, name: name, colour: colour, id: session.id)
                dailySessions[sessionDay, default: []].append(block)
            } else {
                for split in Calendar.current.studyDaySplit(start: session.start, end: end) {
                    let sessionDay = Calendar.current.startOfDay(for: split.dayStart)
                    let splitDuration = split.duration.rounded(.down)
                    dailyTotals[sessionDay, default: 0] += splitDuration
                    let block = SessionBlock(duration: splitDuration, start: split.start, name: name, colour: colour, id: session.id)
                    dailySessions[sessionDay, default: []].append(block)
                }
            }
        }
        return (dailyTotals, dailySessions)
    }
}
