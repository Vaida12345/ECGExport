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
    
    @State private var operation = OperationType.export
    
    let coordinator: Coordinator
    let watchCoordinator: WatchCoordinator
    
    @Environment(\.scenePhase) private var scenePhase
    
    
    
    var body: some View {
        Group {
            switch coordinator.stage {
            case .idle:
                VStack {
                    SelectionCell(operation: $operation, tag: .export)
                    SelectionCell(operation: $operation, tag: .monitor)
                    
                    Spacer()
                    
                    Button {
                        switch operation {
                        case .export:
                            self.startExport()
                        case .monitor:
                            self.startMonitor()
                        }
                    } label: {
                        Text("Start \(operation.verb)ing")
                            .contentTransition(.numericText())
                            .padding(.horizontal)
                            .padding(.vertical, 3)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                }
            case .working:
                switch operation {
                case .export:
                    ExportProgressView(progresses: coordinator.progress)
                        .animation(.spring, value: coordinator.progress)
                case .monitor:
                    SessionView(watchCoordinator: watchCoordinator)
                }
            case .finished:
                CompletionView()
            }
        }
    }
    
    
    func startExport() {
        let logger = Logger(subsystem: "ECG Export", category: "Export")
        logger.log("Start to export")
        
        self.coordinator.reset()
        
        Task {
            await withErrorPresented("Failed to export health data") {
                try await self.coordinator.update()
                logger.log("Export finished")
            } errorHandler: {
                self.coordinator.reset()
            }
        }
    }
    
    func startMonitor() {
        withErrorPresented("Failed to start monitoring") {
            try watchCoordinator.start()
            self.coordinator.stage = .working
        } errorHandler: {
            self.coordinator.reset()
        }
    }
}

#Preview {
    ContentView(coordinator: .preview, watchCoordinator: .init())
        .background(Color.listBackground)
}
