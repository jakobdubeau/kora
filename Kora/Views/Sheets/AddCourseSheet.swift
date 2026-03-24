//
//  AddCourseSheet.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-02-06.
//

import SwiftUI
import SwiftData

struct AddCourse: View {
    @Environment(\.modelContext) private var context // db session
    @Environment(\.dismiss) private var dismiss // close the modal
    
    @State private var name: String = "" // @State to redraw when value changes
    @State private var selectedFamily: Int? = nil
    @State private var selectedColor: String = Color.palettes[0].shades[2]
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    TextField("Course name", text: $name) // $ binds input text to the var
                }
                .frame(height: 130)
                
                // color picker
                
                if let family = selectedFamily {
                    HStack(spacing:12) {
                        Image(systemName: "chevron.left")
                              .foregroundStyle(.secondary)
                              .onTapGesture {
                                  withAnimation {
                                      selectedFamily = nil
                                  }
                              }
                        ForEach(Array(Color.palettes[family].shades.enumerated()), id: \.offset) { index, hex in
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 28, height: 28)
                                    .transition(.scale.combined(with: .opacity))
                                    .animation(.spring(duration: 0.3).delay(Double(index) * 0.05), value: selectedFamily)
                                    .overlay(
                                        Circle().strokeBorder(.primary, lineWidth: selectedColor == hex ? 2 : 0)
                                    )
                                    .onTapGesture {
                                        withAnimation {
                                            selectedColor = hex
                                        }
                                    }
                        }
                    }
                }
                else {
                    HStack(spacing:12) {
                        ForEach(0..<Color.palettes.count, id: \.self) { index in
                            let palette = Color.palettes[index]
                            Circle()
                                .fill(Color(hex: palette.shades[2]))
                                .frame(width: 28, height: 28)
                                .transition(.scale.combined(with: .opacity))
                                .animation(.spring(duration: 0.3).delay(Double(index) * 0.05), value: selectedFamily)
                                .overlay(
                                    Circle().strokeBorder(.primary, lineWidth: selectedFamily == index ? 2 : 0)
                                )
                                .onTapGesture {
                                    withAnimation {
                                        selectedFamily = index
                                        selectedColor = palette.shades[2]
                                    }
                                }
                        }
                    }
                }
                Spacer()
            }
            .navigationTitle("Add Course")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        context.insert(Course(name: name, colour: selectedColor)) // add new model to swift data
                        dismiss()
                    }.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) // disable done if no name/only spaces
                }
            }
        }
    }
}
