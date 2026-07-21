//
//  EditSessionSheet.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-07-12.
//

import SwiftUI

struct EditSession: View {
    
    let lowerBound: Date
    let upperBound: Date
    let initialStart: Date
    let initialEnd: Date
    
    let onCancel: () -> Void
    let onSave: (Date, Date) -> Void
    
    @State private var startHour: Int = 0
    @State private var startMinute: Int = 0
    @State private var endHour: Int = 0
    @State private var endMinute: Int = 0
    @State private var startPM: Bool = false
    @State private var endPM: Bool = false
    
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
                        startPM = false
                    } label: {
                        Text("AM")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(startPM ? Color(.separator) : Color.white)
                            .fontDesign(.monospaced)
                    }
                    Button {
                        startPM = true
                    } label: {
                        Text("PM")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(startPM ? Color.white : Color(.separator))
                            .fontDesign(.monospaced)
                    }
                }
                
                TextField("", text: Binding(
                    get: { String(format: "%02d:%02d", startHour, startMinute) },
                    set: {
                        startHour = Int(String($0.prefix(2))) ?? startHour
                        startMinute = Int(String($0.suffix(2))) ?? startMinute
                    }
                ))
                .font(.system(size: 34, weight: .regular))
                .fontDesign(.monospaced)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }

            HStack(spacing: 16) {
                Text("End")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 48, alignment: .leading)

                VStack(spacing: 8) {
                    Button {
                        endPM = false
                    } label: {
                        Text("AM")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(endPM ? Color(.separator) : Color.white)
                            .fontDesign(.monospaced)
                    }
                    Button {
                        endPM = true
                    } label: {
                        Text("PM")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(endPM ? Color.white : Color(.separator))
                            .fontDesign(.monospaced)
                    }
                }

                TextField("", text: Binding(
                    get: { String(format: "%02d:%02d", endHour, endMinute) },
                    set: {
                        endHour = Int(String($0.prefix(2))) ?? endHour
                        endMinute = Int(String($0.suffix(2))) ?? endMinute
                    }
                ))
                .font(.system(size: 34, weight: .regular))
                .fontDesign(.monospaced)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
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
                    save()
                } label: {
                    Text("Save")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.white)
                }
            }
            .padding(.top, 4)
        }
        .padding(24)
        .frame(width: 275)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.secondarySystemBackground))
        )
        .onAppear {
            // convert swift Date into readable hour/mins
            let startTime = Calendar.current.dateComponents([.hour, .minute], from: initialStart)
            let start = startTime.hour ?? 0 // 24-hour time
            startPM = start >= 12
            startHour = start % 12 == 0 ? 12 : start % 12
            startMinute = startTime.minute ?? 0

            let endTime = Calendar.current.dateComponents([.hour, .minute], from: initialEnd)
            let end = endTime.hour ?? 0
            endPM = end >= 12
            endHour = end % 12 == 0 ? 12 : end % 12
            endMinute = endTime.minute ?? 0
        }
    }

    private func save() {

    }
}

#Preview {
    EditSession(
        lowerBound: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: .now)!,
        upperBound: Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: .now)!,
        initialStart: Calendar.current.date(bySettingHour: 16, minute: 35, second: 0, of: .now)!,
        initialEnd: Calendar.current.date(bySettingHour: 17, minute: 2, second: 0, of: .now)!,
        onCancel: {},
        onSave: { _, _ in }
    )
    .padding()
}
