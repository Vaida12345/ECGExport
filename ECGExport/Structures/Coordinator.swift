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
    
    var stage: Stage = .idle
    
    
    static var preview: Coordinator {
        Coordinator(progress: [ExportProgress(name: "Preview", systemImage: "pencil.slash")])
    }
    
    
    func reset() {
        self.progress.removeAll()
        self.stage = .idle
    }
    
    
    init(progress: [ExportProgress] = []) {
        self.progress = progress
    }
    
    public static func == (_ lhs: Coordinator, _ rhs: Coordinator) -> Bool {
        lhs.progress == rhs.progress &&
        lhs.stage == rhs.stage
    }
    
    
    enum Stage: Equatable {
        case idle
        case working
        case finished
    }
    
}
