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
    
    @Query private var courses: [Course]

    @State private var name: String = "" // @State to redraw when value changes
    @State private var selectedFamily: Int? = nil
    @State private var selectedColor: String = Color.palettes[8].shades[0]
    @State private var showShades: Bool = false // animation
    @State private var counter: Int = 0
    @FocusState private var nameFocused: Bool
    
    var body: some View {
        GeometryReader { _ in
            VStack {
                ZStack {
                    Text("Add Course")
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
                            context.insert(Course(name: name, colour: selectedColor, sortOrder: (courses.map(\.sortOrder).max() ?? -1) + 1)) // add new model to swift data
                            dismiss()
                        } label: {
                            Text("Done")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color(.separator) : Color.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 32)
                                        .stroke(Color(.separator).opacity(0.5), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) // disable done if no name/only spaces
                    }
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 22)
                
                TextField("e.g. Math", text: $name)
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
                                .fill(Color(hex: palette.shades[2]))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Circle().strokeBorder(.primary, lineWidth: selectedFamily == index ? 3 : 0)
                                )
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
                                .animation(.easeIn(duration: 0.05), value: showShades)
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
        ForEach(Array(shades.enumerated()), id: \.offset) { index, hex in // ForEach is for building views
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
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                        selectedColor = hex
                    }
                }
        }
        .onAppear { appeared = true }
    }
}
