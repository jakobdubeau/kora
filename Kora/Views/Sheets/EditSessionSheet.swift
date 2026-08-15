//
//  EditSessionSheet.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-07-12.
//

import SwiftUI

struct EditSession: View {
    
    enum Row { case start, end }
    
    struct Cursor: Equatable {
        let row: Row
        let segment: TimeSegment
    }
    
    let lowerBound: Date
    let upperBound: Date
    let initialStart: Date
    let initialEnd: Date
    
    let onCancel: () -> Void
    let onSave: (Date, Date) -> Void
    
    @State private var start: TimeEntry
    @State private var end: TimeEntry
    @State private var cursor: Cursor?
    
    init(
        lowerBound: Date,
        upperBound: Date,
        initialStart: Date,
        initialEnd: Date,
        onCancel: @escaping () -> Void,
        onSave: @escaping (Date, Date) -> Void
    ) {
        self.lowerBound = lowerBound
        self.upperBound = upperBound
        self.initialStart = initialStart
        self.initialEnd = initialEnd
        self.onCancel = onCancel
        self.onSave = onSave

        _start = State(initialValue: TimeEntry(initialStart))
        _end = State(initialValue: TimeEntry(initialEnd))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Edit Session")
                .font(.headline.bold())
                .frame(maxWidth: .infinity, alignment: .center)
            
            HStack(spacing: 16) {
                Text("Start")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 48, alignment: .leading)
                
                VStack(spacing: 8) {
                    Button {
                        start.isPM = false
                    } label: {
                        Text("AM")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(start.isPM ? Color(.separator) : Color.white)
                            .fontDesign(.monospaced)
                    }
                    Button {
                        start.isPM = true
                    } label: {
                        Text("PM")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(start.isPM ? Color.white : Color(.separator))
                            .fontDesign(.monospaced)
                    }
                }
                // start time
                TimeField(
                    entry: start,
                    active: cursor?.row == .start ? cursor?.segment : nil,
                    onTap: { cursor = Cursor(row: .start, segment: $0) }
                )
            }

            HStack(spacing: 16) {
                Text("End")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 48, alignment: .leading)

                VStack(spacing: 8) {
                    Button {
                        end.isPM = false
                    } label: {
                        Text("AM")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(end.isPM ? Color(.separator) : Color.white)
                            .fontDesign(.monospaced)
                    }
                    Button {
                        end.isPM = true
                    } label: {
                        Text("PM")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(end.isPM ? Color.white : Color(.separator))
                            .fontDesign(.monospaced)
                    }
                }

                // end time
                TimeField(
                    entry: end,
                    active: cursor?.row == .end ? cursor?.segment : nil,
                    onTap: { cursor = Cursor(row: .end, segment: $0) }
                )
            }

            // save and cancel
            HStack(spacing: 24) {
                Spacer()

                Button {
                    onCancel()
                } label: {
                    Text("Cancel")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.white)
                }

                Button {
                    onSave(resolve(start), resolve(end))
                } label: {
                    Text("Save")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(canSave ? Color.white : Color(.separator))
                }
                .disabled(!canSave)
            }
        }
        .padding(24)
        .frame(width: 275)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.secondarySystemBackground))
        )
        .contentShape(Rectangle())
        .onTapGesture { cursor = nil }
        .overlay(
            DigitCatcher(isActive: cursor != nil, onInsert: insert, onDelete: delete)
                .frame(width: 0, height: 0)
                .allowsHitTesting(false)
        )
        .onChange(of: cursor) { old, _ in commit(old) }
    }

    private func binding(for row: Row) -> Binding<TimeEntry> {
        row == .start ? $start : $end
    }

    private func insert(_ digit: Character) {
        guard let cursor else { return }
        let entry = binding(for: cursor.row)
        var segment = cursor.segment

        if segment == .hour && entry.wrappedValue.hour.count == 2 {
            segment = .minute
            self.cursor = Cursor(row: cursor.row, segment: .minute)
        }

        let current = entry.wrappedValue.text(for: segment)
        guard current.count < 2 else { return }

        let filled = segment.clean(current + String(digit))

        if segment == .hour {
            entry.wrappedValue.hour = filled
            if filled.count == 2 { self.cursor = Cursor(row: cursor.row, segment: .minute) }
        } else {
            entry.wrappedValue.minute = filled
        }
    }

    private func delete() {
        guard let cursor else { return }
        let entry = binding(for: cursor.row)

        if cursor.segment == .hour {
            entry.wrappedValue.hour = entry.wrappedValue.trimmed(for: .hour)
            return
        }

        if entry.wrappedValue.minute.isEmpty {
            self.cursor = Cursor(row: cursor.row, segment: .hour)
            entry.wrappedValue.hour = entry.wrappedValue.trimmed(for: .hour)
            return
        }

        let shorter = entry.wrappedValue.trimmed(for: .minute)
        entry.wrappedValue.minute = shorter

        if shorter.isEmpty {
            self.cursor = Cursor(row: cursor.row, segment: .hour)
        }
    }

    private func commit(_ leaving: Cursor?) {
        guard let leaving else { return }
        let entry = binding(for: leaving.row)

        switch leaving.segment {
        case .hour: entry.wrappedValue.hour = leaving.segment.normalize(entry.wrappedValue.hour)
        case .minute: entry.wrappedValue.minute = leaving.segment.normalize(entry.wrappedValue.minute)
        }
    }

    private func resolve(_ entry: TimeEntry) -> Date {
        let hour = entry.hour12
        let hour24 = hour == 12 ? (entry.isPM ? 12 : 0) : (entry.isPM ? hour + 12 : hour)
        let dayStart = Calendar.current.studyDayStart(for: initialStart)
        let day = hour24 < 5 ? Calendar.current.date(byAdding: .day, value: 1, to: dayStart)! : dayStart
        return Calendar.current.date(bySettingHour: hour24, minute: entry.minutes, second: 0, of: day)!
    }

    private var canSave: Bool {
        let from = resolve(start)
        let to = resolve(end)

        guard to > from else { return false }
        guard to <= Date.now else { return false }
        guard from >= lowerBound, to <= upperBound else { return false }
        
        return from != resolve(TimeEntry(initialStart)) || to != resolve(TimeEntry(initialEnd))
    }
}

#Preview {
    EditSession(
        lowerBound: Calendar.current.date(byAdding: .hour, value: -6, to: .now)!,
        upperBound: .now,
        initialStart: Calendar.current.date(byAdding: .minute, value: -90, to: .now)!,
        initialEnd: Calendar.current.date(byAdding: .minute, value: -60, to: .now)!,
        onCancel: {},
        onSave: { _, _ in }
    )
    .padding()
}
