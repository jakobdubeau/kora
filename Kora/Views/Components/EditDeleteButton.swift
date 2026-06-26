//
//  EditDeleteButton.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-06-25.
//

import SwiftUI

struct EditDeleteButton: View {

    let onEdit: () -> Void
    let onDelete: () -> Void
    @Binding var isDismissing: Bool
    let onDismissComplete: () -> Void

    @State private var editOffset: CGFloat = 316
    @State private var deleteOffset: CGFloat = 300

    var body: some View {
        VStack(spacing: 4) {
            Button {
                onEdit()
            } label: {
                Text("Edit")
                    .font(.system(size: 14, weight: .semibold))
            }
            .buttonStyle(.plain)
            .frame(width: 72, height: 30)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Color(.separator).opacity(0.5), lineWidth: 1))
            .padding(.trailing, 16)
            .offset(x: editOffset)

            Button {
                onDelete()
            } label: {
                Text("Delete")
                    .font(.system(size: 14, weight: .semibold))
            }
            .buttonStyle(.plain)
            .frame(width: 72, height: 30)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Color(.separator).opacity(0.5), lineWidth: 1))
            .padding(.leading, 16)
            .offset(x: deleteOffset)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.22)) { editOffset = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
                withAnimation(.easeOut(duration: 0.22)) { deleteOffset = 0 }
            }
        }
        .onChange(of: isDismissing) { _, new in
            guard new else { return }
            withAnimation(.easeIn(duration: 0.22)) { deleteOffset = 300 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeIn(duration: 0.22)) { editOffset = 316 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                onDismissComplete()
            }
        }
    }
}

#Preview {
    EditDeleteButton(
        onEdit: {},
        onDelete: {},
        isDismissing: .constant(false),
        onDismissComplete: {}
    )
    .padding()
}
