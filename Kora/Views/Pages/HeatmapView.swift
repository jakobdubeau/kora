//
//  HeatmapView.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

import SwiftUI

struct HeatmapView: View {
    @State private var vm = HeatmapViewModel()
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            HStack(spacing: 22) {
                Button {

                } label: {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.plain)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
                // use Color(.separator).opacity(0.5) for disabled (end)
                
                Text(Date(), format: .dateTime.month())
                    .font(.headline.bold())
                
                Button {

                } label: {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.plain)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
            }
            VStack {
                HeatmapGrid(dailyTotals: vm.dailyTotals, onTap: {_ in})
            }
            .padding(.vertical, 22)
            .padding(.horizontal, 42)
            
            Rectangle()
                .foregroundStyle(Color(.separator).opacity(0.5))
                .frame(height: 0.5)
            ScrollView {
                Text("blocks")
            }
        }
        .padding(.top, 24)
    }
}
