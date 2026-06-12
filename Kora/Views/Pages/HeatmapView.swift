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
        VStack(alignment: .center) {
            Text(Date(), format: .dateTime.month())
                .font(.headline.bold())
        }
    }
}
