//
//  Coordinator.swift
//  ECGExport
//
//  Created by Vaida on 3/22/25.
//

import Observation


@MainActor
@Observable
final class Coordinator: @preconcurrency Equatable {
    
    var progress: [ExportProgress]
    
    var allFinished = false
    
    
    static var preview: Coordinator {
        Coordinator(progress: [ExportProgress(name: "Preview", systemImage: "pencil.slash")])
    }
    
    
    func reset() {
        self.progress.removeAll()
        self.allFinished = false
    }
    
    
    init(progress: [ExportProgress] = []) {
        self.progress = progress
    }
    
    public static func == (_ lhs: Coordinator, _ rhs: Coordinator) -> Bool {
        lhs.progress == rhs.progress &&
        lhs.allFinished == rhs.allFinished
    }
    
}
