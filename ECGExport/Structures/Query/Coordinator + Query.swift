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
    
    @MainActor
    func authorize(healthStore: HKHealthStore) async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw UpdateError.noHealthData
        }
        
        let readTypes: Set<HKObjectType> = [ // FIXME: change the read types.
            HKObjectType.electrocardiogramType(),
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
        ]
        
        try await healthStore.requestAuthorization(toShare: [], read: readTypes)
    }
    
    nonisolated func update() async throws {
        await MainActor.run {
            withAnimation {
                self.stage = .working
            }
        }
        
        let healthStore = HKHealthStore()
        
        try await self.authorize(healthStore: healthStore)
        
        
        try await self.storeECG(from: healthStore)
        
        try await self.storeQuantity(from: healthStore, name: "Heart Rate", systemImage: "heart.fill", identifier: .heartRate, unit: .count().unitDivided(by: .minute()), additionalNames: ["motionContext"]) { row, sample in
            row[.custom("motionContext")] = (sample.metadata?[HKMetadataKeyHeartRateMotionContext] as? NSNumber).flatMap({ HKHeartRateMotionContext(rawValue: $0.intValue)?.description }) ?? ""
        }
        
        try await self.storeQuantity(
            from: healthStore, name: "Heart Rate Variability", systemImage: "arrow.up.heart.fill",
            identifier: .heartRateVariabilitySDNN,
            unit: .second())
        
        try await self.storeQuantity(
            from: healthStore, name: "Oxygen Saturation", systemImage: "drop.degreesign.fill",
            identifier: .oxygenSaturation,
            unit: .percent())
        
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
