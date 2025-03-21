//
//  ContentView.swift
//  ECGExport
//
//  Created by Vaida on 3/21/25.
//

import SwiftUI
import OSLog
import Essentials


struct ContentView: View {
    
    @State private var coordinator = Coordinator()
    
    @Environment(\.scenePhase) private var scenePhase
    
    
    var body: some View {
        Group {
            if coordinator.current != coordinator.total {
                VStack {
                    if let total = coordinator.total {
                        ProgressView("", value: Double(coordinator.current) / Double(total))
                    } else {
                        ProgressView()
                    }
                    
                    Text("Loading")
                }
            } else {
                ContentUnavailableView("Done", systemImage: "checkmark")
            }
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            guard newValue == .active else { return }
            
            let logger = Logger(subsystem: "ECG Export", category: "Export")
            logger.log("Start to export")
            
            self.coordinator.reset()
            
            Task {
                await withErrorPresented("Failed to export ECG") {
                    try await self.coordinator.update()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
