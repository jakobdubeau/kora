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

    @State private var editOffset: CGFloat = 122
    @State private var deleteOffset: CGFloat = 100

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
            .background(RoundedRectangle(cornerRadius: 32).fill(Color(.systemBackground)))
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Color(.separator).opacity(0.5), lineWidth: 1))
            .padding(.trailing, 22)
            .offset(x: editOffset)

            Button(role: .destructive) {
                onDelete()
            } label: {
                Text("Delete")
                    .font(.system(size: 14, weight: .semibold))
            }
            .buttonStyle(.plain)
            .frame(width: 72, height: 30)
            .background(RoundedRectangle(cornerRadius: 32).fill(Color(.systemBackground)))
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Color(.separator).opacity(0.5), lineWidth: 1))
            .padding(.leading, 22)
            .offset(x: deleteOffset)
        }
        .onAppear {
            withAnimation(.spring(response: 0.30, dampingFraction: 0.9)) { editOffset = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.09) {
                withAnimation(.spring(response: 0.30, dampingFraction: 0.9)) { deleteOffset = 0 }
            }
        }
        .onChange(of: isDismissing) { _, new in
            guard new else { return }
            withAnimation(.spring(response: 0.25, dampingFraction: 1.0)) { deleteOffset = 100 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                withAnimation(.spring(response: 0.25, dampingFraction: 1.0)) { editOffset = 122 }
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
