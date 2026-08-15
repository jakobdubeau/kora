//
//  TimeField.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-08-14.
//

import SwiftUI

struct TimeField: View {

    let entry: TimeEntry
    let active: TimeSegment?
    let onTap: (TimeSegment) -> Void

    var body: some View {
        let hours = Array((entry.hour.isEmpty ? entry.hourPlaceholder : entry.hour)
            .padding(toLength: 2, withPad: " ", startingAt: 0))
        let minutes = Array((entry.minute.isEmpty ? entry.minutePlaceholder : entry.minute)
            .padding(toLength: 2, withPad: " ", startingAt: 0))
        
        let hourCaret: Alignment = entry.hour.count == 1 ? .center : entry.hour.isEmpty ? .leading : .trailing
        let minuteCaret: Alignment = entry.minute.count == 1 ? .center : entry.minute.isEmpty ? .leading : .trailing

        HStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(String(hours[0]))
                    .font(.system(size: 36, weight: .regular))
                    .fontDesign(.monospaced)
                    .foregroundStyle(entry.hour.isEmpty ? Color(.separator) : .white)

                Text(String(hours[1]))
                    .font(.system(size: 36, weight: .regular))
                    .fontDesign(.monospaced)
                    .foregroundStyle(entry.hour.isEmpty ? Color(.separator) : .white)
            }
            .overlay(alignment: hourCaret) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.white)
                    .frame(width: 2, height: 32)
                    .opacity(active == .hour ? 1 : 0)
            }
            .frame(width: 48)
            .contentShape(Rectangle())
            .onTapGesture { onTap(.hour) }

            Text(":")
                .font(.system(size: 32))
                .fontDesign(.monospaced)
                .foregroundStyle(entry.hour.isEmpty || entry.minute.isEmpty ? Color(.separator) : .white)
                .baselineOffset(3)

            HStack(spacing: 0) {
                Text(String(minutes[0]))
                    .font(.system(size: 36, weight: .regular))
                    .fontDesign(.monospaced)
                    .foregroundStyle(entry.minute.isEmpty ? Color(.separator) : .white)

                Text(String(minutes[1]))
                    .font(.system(size: 36, weight: .regular))
                    .fontDesign(.monospaced)
                    .foregroundStyle(entry.minute.isEmpty ? Color(.separator) : .white)
            }
            .overlay(alignment: minuteCaret) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.white)
                    .frame(width: 2, height: 32)
                    .opacity(active == .minute ? 1 : 0)
            }
            .frame(width: 48)
            .contentShape(Rectangle())
            .onTapGesture { onTap(.minute) }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

// custom keyboard handling
struct DigitCatcher: UIViewRepresentable {

    let isActive: Bool
    let onInsert: (Character) -> Void
    let onDelete: () -> Void

    func makeUIView(context: Context) -> KeyView { KeyView() }

    func updateUIView(_ view: KeyView, context: Context) {
        view.onInsert = onInsert
        view.onDelete = onDelete

        guard isActive != view.isFirstResponder else { return }
        DispatchQueue.main.async {
            if isActive { view.becomeFirstResponder() } else { view.resignFirstResponder() }
        }
    }

    final class KeyView: UIView, UIKeyInput {
        var onInsert: ((Character) -> Void)?
        var onDelete: (() -> Void)?

        var keyboardType: UIKeyboardType = .numberPad
        override var canBecomeFirstResponder: Bool { true }

        var hasText: Bool { true }

        func insertText(_ text: String) {
            for character in text where character.isNumber { onInsert?(character) }
        }

        func deleteBackward() { onDelete?() }
    }
}
