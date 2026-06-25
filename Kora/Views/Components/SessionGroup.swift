//
//  SessionGroup.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-04-10.
//

import SwiftUI

struct SessionGroup: View {
    
    var body: some View {
        VStack {
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: 16)
            .fill(Color(hex: "#080809"))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.separator).opacity(0.5), lineWidth: 0.5))
        )
    }
}
