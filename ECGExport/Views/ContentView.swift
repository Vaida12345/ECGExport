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
            if coordinator.stage != .finished {
                ExportProgressView(progresses: coordinator.progress)
            } else {
                CompletionView()
            }
        }
        .animation(.spring, value: coordinator.progress)
        .onChange(of: scenePhase) { oldValue, newValue in
            guard newValue == .active else { return }
            guard coordinator.stage != .working else { return }
            
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
