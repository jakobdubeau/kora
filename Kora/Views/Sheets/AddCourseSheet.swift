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
    @State private var showBack: Bool = false

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

                ZStack {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 30) {
                        ForEach(0..<Color.palettes.count, id: \.self) { index in
                            let palette = Color.palettes[index]

                            Circle()
                                .fill(Color(hex: palette.shades[2]))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Circle().strokeBorder(.primary, lineWidth: selectedFamily == index ? 3 : 0)
                                )
                                .onTapGesture {
                                    selectedFamily = index
                                    selectedColor = palette.shades[2]

                                    withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                                        showShades = true
                                        showBack = true
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .opacity(showShades ? 0 : 1)
                    .scaleEffect(showShades ? 0.95 : 1)
                    .animation(
                        showShades
                            ? .spring(response: 0.4, dampingFraction: 0.95)
                            : .spring(response: 0.4, dampingFraction: 0.95)
                                .delay(0.05),
                        value: showShades
                    )
                    .allowsHitTesting(!showShades)

                    if let family = selectedFamily {
                        ZStack {
                            Image(systemName: "chevron.left")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                .padding(.leading, 35)
                                .opacity(showBack ? 1 : 0)
                                .scaleEffect(showBack ? 1 : 0.9)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.28, dampingFraction: 0.88)) {
                                        showShades = false
                                        showBack = false
                                    }
                                }

                            ForEach(Array(Color.palettes[family].shades.enumerated()), id: \.offset) { index, hex in
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Circle().strokeBorder(.primary, lineWidth: selectedColor == hex ? 3 : 0)
                                    )
                                    .scaleEffect(showShades ? 1 : 0)
                                    .opacity(showShades ? 1 : 0)
                                    .offset(showShades ? shadeOffset(index: index, radius: 130) : .zero)
                                    .animation(
                                        showShades
                                            ? .spring(response: 0.25, dampingFraction: 0.95)
                                            .delay((Double(index) + 1) * 0.07)
                                        : .easeInOut(duration: 0.2),
                                        value: showShades
                                    )
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                            selectedColor = hex
                                        }
                                    }
                            }
                        }
                        .id(family)
                        .allowsHitTesting(showShades)
                    }
                }
                .frame(height: 340)
                
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
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) // disable done if no name/only spaces
                }
            }
        }
    }
}
