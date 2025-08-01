//
//  Coordinator + Query.swift
//  ECGExport
//
//  Created by Vaida on 2025-07-30.
//

import HealthKit
import Essentials
import SwiftUI


extension Coordinator {
    
    nonisolated func update() async throws {
        
        // MARK: - Ask for permission
        let healthStore = HKHealthStore()
        
        guard HKHealthStore.isHealthDataAvailable() else {
            throw UpdateError.noHealthData
        }
        
        let readTypes: Set<HKObjectType> = [ // FIXME: change the read types.
            HKObjectType.electrocardiogramType(),
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        ]
        
        try await healthStore.requestAuthorization(toShare: [], read: readTypes)
        
        
        try await self.storeECG(from: healthStore)
        try await self.storeHeartRate(from: healthStore)
        
        await MainActor.run {
            withAnimation {
                self.stage = .finished
            }
        }
    }
    
    enum UpdateError: GenericError {
        case noHealthData
        case accessDenied
        case invalidSample
        
        var message: String {
            switch self {
            case .noHealthData:
                "No Health Data Available"
            case .accessDenied:
                "Access Denied"
            case .invalidSample:
                "Invalid Sample"
            }
        }
    }
    
}
