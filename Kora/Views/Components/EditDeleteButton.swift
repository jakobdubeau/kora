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
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Color(.separator).opacity(0.5), lineWidth: 1))
            .padding(.trailing, 22)
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
            .padding(.leading, 22)
            .offset(x: deleteOffset)
        }
        .onAppear {
            withAnimation(.linear(duration: 0.14)) { editOffset = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.11) {
                withAnimation(.linear(duration: 0.14)) { deleteOffset = 0 }
            }
        }
        .onChange(of: isDismissing) { _, new in
            guard new else { return }
            withAnimation(.linear(duration: 0.09)) { deleteOffset = 100 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                withAnimation(.linear(duration: 0.09)) { editOffset = 122 }
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
