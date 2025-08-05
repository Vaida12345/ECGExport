//
//  ContentView.swift
//  ECGReader Watch App
//
//  Created by Vaida on 2025-08-04.
//

import SwiftUI
import WatchConnectivity
import Essentials


struct ContentView: View {
    
    let watchCoordinator: WatchCoordinator
    
    let coordinator = Coordinator.shared
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Hear Rate")
                .font(.headline)
            
            Text(coordinator.heartRate?.formatted(.number.precision(2)) ?? "loading")
            
            Text("bpm")
                .font(.caption)
        }
        .task {
            await withErrorPresented("Failed to fetch data") {
                try await coordinator.startMonitor()
            }
        }
    }
}

#Preview {
    ContentView(watchCoordinator: .shared)
}
