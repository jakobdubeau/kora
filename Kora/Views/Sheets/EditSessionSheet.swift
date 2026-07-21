//
//  EditSessionSheet.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-07-12.
//

import SwiftUI

struct EditSession: View {
    
    enum Field: Hashable { case startHour, startMinute, endHour, endMinute }
    @FocusState private var focusedField: Field?
    
    let lowerBound: Date
    let upperBound: Date
    let initialStart: Date
    let initialEnd: Date
    
    let onCancel: () -> Void
    let onSave: (Date, Date) -> Void
    
    @State private var startHour: String = ""
    @State private var startMinute: String = ""
    @State private var endHour: String = ""
    @State private var endMinute: String = ""
    @State private var startPM: Bool = false
    @State private var endPM: Bool = false
    
    private var initialStartHour: String {
        let startTime = Calendar.current.dateComponents([.hour, .minute], from: initialStart)
        let start = startTime.hour ?? 0 // 24-hour time
        let hour = start % 12 == 0 ? 12 : start % 12
        return String(format: "%02d", hour)
    }
    
    private var initialStartMinute: String {
        let startTime = Calendar.current.dateComponents([.hour, .minute], from: initialStart)
        let minute = startTime.minute ?? 0
        return String(format: "%02d", minute)
    }
    
    private var initialEndHour: String {
        let endTime = Calendar.current.dateComponents([.hour, .minute], from: initialEnd)
        let end = endTime.hour ?? 0 // 24-hour time
        let hour = end % 12 == 0 ? 12 : end % 12
        return String(format: "%02d", hour)
    }
    
    private var initialEndMinute: String {
        let endTime = Calendar.current.dateComponents([.hour, .minute], from: initialEnd)
        let minute = endTime.minute ?? 0
        return String(format: "%02d", minute)
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
                // start time
                HStack(spacing: 0) {
                    TextField("", text: $startHour)
                        .focused($focusedField, equals: .startHour)
                        .font(.system(size: 34, weight: .regular))
                        .foregroundStyle(.white)
                        .fontDesign(.monospaced)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 44)
                        .overlay(alignment: .trailing) {
                            if startHour.isEmpty {
                                Text(initialStartHour)
                                    .font(.system(size: 34, weight: .regular))
                                    .fontDesign(.monospaced)
                                    .foregroundStyle(Color(.separator))
                                    .allowsHitTesting(false)
                            }
                        }
                    
                    Text(":")
                        .font(.system(size: 34))
                        .fontDesign(.monospaced)
                        .foregroundStyle(startHour.isEmpty || startMinute.isEmpty ? Color(.separator) : .white)
                    
                    TextField("", text: $startMinute)
                        .focused($focusedField, equals: .startMinute)
                        .font(.system(size: 34, weight: .regular))
                        .foregroundStyle(.white)
                        .fontDesign(.monospaced)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.leading)
                        .frame(width: 44)
                        .overlay(alignment: .leading) {
                            if startMinute.isEmpty {
                                Text(initialStartMinute)
                                    .font(.system(size: 34, weight: .regular))
                                    .fontDesign(.monospaced)
                                    .foregroundStyle(Color(.separator))
                                    .allowsHitTesting(false)
                            }
                        }
                }
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

                // end time
                HStack(spacing: 0) {
                    TextField("", text: $endHour)
                        .focused($focusedField, equals: .endHour)
                        .font(.system(size: 34, weight: .regular))
                        .foregroundStyle(.white)
                        .fontDesign(.monospaced)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 44)
                        .overlay(alignment: .trailing) {
                            if endHour.isEmpty {
                                Text(initialEndHour)
                                    .font(.system(size: 34, weight: .regular))
                                    .fontDesign(.monospaced)
                                    .foregroundStyle(Color(.separator))
                                    .allowsHitTesting(false)
                            }
                        }
                    
                    Text(":")
                        .font(.system(size: 34))
                        .fontDesign(.monospaced)
                        .foregroundStyle(endHour.isEmpty || endMinute.isEmpty ? Color(.separator) : .white)
                    
                    TextField("", text: $endMinute)
                        .focused($focusedField, equals: .endMinute)
                        .font(.system(size: 34, weight: .regular))
                        .foregroundStyle(.white)
                        .fontDesign(.monospaced)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.leading)
                        .frame(width: 44)
                        .overlay(alignment: .leading) {
                            if endMinute.isEmpty {
                                Text(initialEndMinute)
                                    .font(.system(size: 34, weight: .regular))
                                    .fontDesign(.monospaced)
                                    .foregroundStyle(Color(.separator))
                                    .allowsHitTesting(false)
                            }
                        }
                }
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
            let startTime = Calendar.current.dateComponents([.hour, .minute], from: initialStart)
            let start = startTime.hour ?? 0
            startPM = start >= 12

            let endTime = Calendar.current.dateComponents([.hour, .minute], from: initialEnd)
            let end = endTime.hour ?? 0
            endPM = end >= 12
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
