//
//  EditCourseSheet.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-07-12.
//

import SwiftUI

struct EditCourse: View {
    @Environment(\.dismiss) private var dismiss

    let course: Course

    @State private var name: String = ""
    @State private var selectedFamily: Int?
    @State private var selectedColor: String
    @State private var showShades: Bool = false
    @State private var counter: Int = 0
    @FocusState private var nameFocused: Bool

    init(course: Course) {
        self.course = course
        _selectedColor = State(initialValue: course.colour ?? Color.palettes[8].shades[0])
        _selectedFamily = State(initialValue: Color.palettes.firstIndex { $0.shades.contains(course.colour ?? "") })
    }

    private var resolvedName: String {
        let typed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return typed.isEmpty ? course.name : typed
    }

    private var canSave: Bool {
        resolvedName != course.name || selectedColor != (course.colour ?? Color.palettes[8].shades[0])
    }

    var body: some View {
        GeometryReader { _ in
            VStack {
                ZStack {
                    Text("Edit Course")
                        .font(.headline.bold())

                    HStack(spacing: 0) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .font(.system(size: 14, weight: .semibold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 32)
                                        .stroke(Color(.separator).opacity(0.5), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        Button {
                            course.name = resolvedName
                            course.colour = selectedColor
                            dismiss()
                        } label: {
                            Text("Save")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(canSave ? Color.white : Color(.separator))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 32)
                                        .stroke(Color(.separator).opacity(0.5), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(!canSave)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 22)

                TextField(course.name, text: $name)
                    .font(.system(size: 18, weight: .regular))
                    .focused($nameFocused)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(Color(hex: "#090909"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator).opacity(0.5), lineWidth: nameFocused ? 2 : 0.5))
                    .padding(.horizontal, 22)
                    .padding(.top, 10)
                    .padding(.bottom, 58)

                ZStack {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 30) {
                        ForEach(0..<Color.palettes.count, id: \.self) { index in
                            let palette = Color.palettes[index]

                            Circle()
                                .fill(Color(hex: selectedFamily == index ? selectedColor : palette.shades[2]))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Circle().strokeBorder(.primary, lineWidth: selectedFamily == index ? 3 : 0)
                                )
                                .animation(.easeOut(duration: 0.2), value: selectedFamily)
                                .onTapGesture {
                                    nameFocused = false
                                    selectedFamily = index
                                    selectedColor = palette.shades[2]
                                    counter += 1

                                    withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                                        showShades = true
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .opacity(showShades ? 0 : 1)
                    .scaleEffect(showShades ? 0.95 : 1)
                    .animation(
                        .spring(response: 0.45, dampingFraction: 0.9)
                        .delay(showShades ? 0 : 0.1),
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
                                .opacity(showShades ? 1 : 0)
                                .animation(.easeIn(duration: 0.15).delay(showShades ? 0.09 : 0), value: showShades)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.45, dampingFraction: 0.9)
                                        .delay(0.07)) {
                                        showShades = false
                                    }
                                }

                            Shades(
                                shades: Color.palettes[family].shades,
                                show: showShades,
                                selectedColor: $selectedColor
                            )
                            .id(counter)
                        }
                        .allowsHitTesting(showShades)
                    }
                }
                .frame(height: 340)

                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture { nameFocused = false }
        }
        .ignoresSafeArea(.keyboard)
    }
}

private struct Shades: View {
    let shades: [String]
    let show: Bool
    @Binding var selectedColor: String

    @State private var appeared = false

    private func shadeOffset(index: Int, radius: CGFloat) -> CGSize {
        let angle = (2 * .pi / 5) * Double(index) - .pi / 2
        return CGSize(width: Foundation.cos(angle) * radius, height: Foundation.sin(angle) * radius)
    }

    var body: some View {
        ForEach(Array(shades.enumerated()), id: \.offset) { index, hex in
            Circle()
                .fill(Color(hex: hex))
                .frame(width: 100, height: 100)
                .overlay(
                    Circle().strokeBorder(.primary, lineWidth: selectedColor == hex ? 3 : 0)
                )
                .scaleEffect(appeared && show ? 1 : 0)
                .opacity(appeared && show ? 1 : 0)
                .offset(appeared ? shadeOffset(index: index, radius: 130) : .zero)
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.9)
                    .delay(0.29 * pow(Double(index) / Double(max(shades.count - 1, 1)), 0.8)),
                    value: appeared
                )
                .animation(
                    .spring(response: 0.3, dampingFraction: 0.9),
                    value: show
                )
                .onTapGesture {
                    withAnimation(.smooth(duration: 0.2)) {
                        selectedColor = hex
                    }
                }
        }
        .onAppear { appeared = true }
    }
}

#Preview {
    EditCourse(course: Course(name: "Math", colour: Color.palettes[1].shades[3]))
}
