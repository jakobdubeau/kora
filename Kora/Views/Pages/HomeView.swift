//
//  HomeView.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

import SwiftUI

struct HomeView: View {
    @State private var vm = HomeViewModel() // @state ensures viewmodel instance isn't lost (keeps alive across redraws), view owns it
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Total: \(formatTime(seconds: vm.totalTime))") // string interpolation
                    .font(.title2)
                
                Text("Course : \(formatTime(seconds: vm.demoCourseTime))")
                    .font(.title3)
                
                Text("Break : \(formatTime(seconds: vm.breakTime))")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            
            Button {
                vm.toggleCourse()
            } label: {
                Text(vm.isRunningCourse ? "Stop course" : "start course")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            
            Button(role: .destructive) {
                vm.newDay()
            } label: {
                Text("New day reset")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}
