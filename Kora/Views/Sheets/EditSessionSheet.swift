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
    
    @State private var startHour: Int
    @State private var startMinute: Int
    @State private var endHour: Int
    @State private var endMinute: Int
    @State private var startPM: Bool
    @State private var endPM: Bool
    
    var body: some View {
        VStack {
            Text("Edit Session")
                .font(.headline.bold())
            
            HStack(spacing: 16) {
                Text("Start")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                
                VStack {
                    Button {
                        startPM = false
                    } label: {
                        Text("AM")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(startPM ? Color.white : Color(.separator))
                            .fontDesign(.monospaced)
                    }
                    Button {
                        startPM = true
                    } label: {
                        Text("PM")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(startPM ? Color(.separator) : Color.white)
                            .fontDesign(.monospaced)
                    }
                }
            }
            
            HStack(spacing: 16) {
                Text("End")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Spacer()
                
                Button {
                    onCancel()
                } label: {
                    Text("Cancel")
                }
                                
                Button {
                    save()
                } label: {
                    Text("Save")
                }
            }
        }
        .onAppear {
            
        }
    }
    
    private func save() {
        
    }
}
