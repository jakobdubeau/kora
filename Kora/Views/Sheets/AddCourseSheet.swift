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
    @State private var selectedColor: String = Color.palettes[8].shades[0]
    @State private var showShades: Bool = false // animation

    private func shadeOffset(index: Int, radius: CGFloat) -> CGSize {
        let angle = (2 * .pi / 5) * Double(index) - .pi / 2
        return CGSize(width: Foundation.cos(angle) * radius, height: Foundation.sin(angle) * radius)
    }

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    TextField("Course name", text: $name)
                }
                .frame(height: 130)
                .scrollDisabled(true)

                if showShades, let family = selectedFamily {
                    ZStack {
                        Image(systemName: "chevron.left")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .padding(.leading, 35)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    showShades = false
                                }
                            }

                        ForEach(Array(Color.palettes[family].shades.enumerated()), id: \.offset) { index, hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Circle().strokeBorder(.primary, lineWidth: selectedColor == hex ? 3 : 0)
                                )
                                .scaleEffect(showShades ? 1 : 0.01)
                                .opacity(showShades ? 1 : 0)
                                .offset(shadeOffset(index: index, radius: 120))
                                .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.07), value: showShades)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedColor = hex
                                    }
                                }
                        }
                    }
                    .frame(height: 340)
                    .allowsHitTesting(showShades)
                } else {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 30) {
                        ForEach(0..<Color.palettes.count, id: \.self) { index in
                            let palette = Color.palettes[index]
                            Circle()
                                .fill(Color(hex: palette.shades[2]))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Circle().strokeBorder(.primary, lineWidth: selectedFamily == index ? 3 : 0)
                                )
                                .transition(.scale.combined(with: .opacity))
                                .onTapGesture {
                                    selectedFamily = index
                                    selectedColor = palette.shades[2]
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        showShades = true
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .transition(.opacity)
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
