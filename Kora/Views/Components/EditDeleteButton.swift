//
//  EditDeleteButton.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-06-25.
//

import SwiftUI

struct EditDeleteButton: View {
    
    // pass in UUID after setup
    let onEdit: () -> Void
    let onDelete: () -> Void
    
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
        }
    }
}

#Preview {
    EditDeleteButton(onEdit: {}, onDelete: {})
        .padding()
}
