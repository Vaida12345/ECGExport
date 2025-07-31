//
//  ExportProgress.swift
//  ECGExport
//
//  Created by Vaida on 2025-07-30.
//

import SwiftUI


@MainActor
@Observable
final class ExportProgress: Identifiable, @preconcurrency Equatable {
    
    let id = UUID()
    
    let name: String
    
    let systemImage: String
    
    var completedCount: Int = 0
    
    var totalCount: Int = 0
    
    var stage: Stage = .preparing
    
    
    init(name: String, systemImage: String, completedCount: Int = 0, totalCount: Int = 0, stage: Stage = .preparing) {
        self.name = name
        self.systemImage = systemImage
        self.completedCount = completedCount
        self.totalCount = totalCount
        self.stage = stage
    }
    
    public static func == (_ lhs: ExportProgress, _ rhs: ExportProgress) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.systemImage == rhs.systemImage &&
        lhs.completedCount == rhs.completedCount &&
        lhs.totalCount == rhs.totalCount &&
        lhs.stage == rhs.stage
    }
    
    
    var fractionCompleted: Double {
        Double(completedCount) / Double(totalCount) // will not crash runtime
    }
    
    enum Stage: Equatable {
        case preparing
        case working
        case finished
    }
    
}
