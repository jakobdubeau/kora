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

    @State private var editOffset: CGFloat = 60
    @State private var deleteOffset: CGFloat = 60
    @State private var editOpacity: Double = 0
    @State private var deleteOpacity: Double = 0

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
            .opacity(editOpacity)

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
            .opacity(deleteOpacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.12)) { editOpacity = 1 }
            withAnimation(.easeOut(duration: 0.18)) { editOffset = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut(duration: 0.12)) { deleteOpacity = 1 }
                withAnimation(.easeOut(duration: 0.18)) { deleteOffset = 0 }
            }
        }
        .onChange(of: isDismissing) { _, new in
            guard new else { return }
            withAnimation(.easeIn(duration: 0.1)) { deleteOpacity = 0 }
            withAnimation(.easeIn(duration: 0.2)) { deleteOffset = 300 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeIn(duration: 0.1)) { editOpacity = 0 }
                withAnimation(.easeIn(duration: 0.2)) { editOffset = 300 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
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
