//
//  StudySessionModel.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

// single timer session used for totals and such

import SwiftData
import Foundation

@Model
class StudySession {
    var id: UUID // study session id
    var courseId: UUID?
    var start: Date // Date represents absolute point in time
    var end: Date? // optional, either Date value or nil, now we use optional binding when accessing
    var isCompleted: Bool
    var courseName: String?
    var courseColour: String?
    var userId: UUID? // owning account, nil means unclaimed guest data
    
    // computed property (no stored value), value will be calculated every time it's accessed
    var duration: TimeInterval { // TimeInterval is basically a double formatted in seconds
        if let end = end {  // if let end = end is optional binding (cause ? before), if block only runs if end exists / not nil
            return end.timeIntervalSince(start) // elapsed time between start and end, returns seconds as double
        } else {
            return Date().timeIntervalSince(start) // end == nil, uses current time to compute duration
        }
    }
    
    init(courseId: UUID?, start: Date = .now, end: Date? = nil, isCompleted: Bool = false, courseName: String? = nil, courseColour: String? = nil, userId: UUID? = nil) {
        self.id = UUID()
        self.courseId = courseId
        self.start = start
        self.end = end
        self.isCompleted = isCompleted
        self.courseName = courseName
        self.courseColour = courseColour
        self.userId = userId
    }
}
