//
//  Coordinator.swift
//  ECGExport
//
//  Created by Vaida on 3/22/25.
//

import Observation
import HealthKit
import FinderItem
import Tabular
import Essentials


@MainActor
@Observable
final class Coordinator {
    
    var current: Int = 0
    
    var total: Int? = nil
    
    
    enum TabularKeys: String, TabularKey {
        case timeStamp
        case value
    }
    
    
    func reset() {
        self.current = 0
        self.total = nil
    }
    
    
    func update() async throws {
        
        // MARK: - Ask for permission
        let healthStore = HKHealthStore()
        
        guard HKHealthStore.isHealthDataAvailable() else {
            throw UpdateError.noHealthData
        }
        
        let readTypes: Set<HKObjectType> = [
            HKObjectType.electrocardiogramType()
        ]
        
        let writeTypes: Set<HKSampleType> = []
        
        let _: Void = try await withCheckedThrowingContinuation { continuation in
            healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: UpdateError.noHealthData)
                }
            }
        }
        
        
        // MARK: - Query for ECG
        // Create the electrocardiogram sample type.
        let ecgType = HKObjectType.electrocardiogramType()
        
        let ECGSamples: [HKElectrocardiogram] = try await withCheckedThrowingContinuation { continuation in
            // Query for electrocardiogram samples
            let ecgQuery = HKSampleQuery(sampleType: ecgType,
                                         predicate: nil,
                                         limit: HKObjectQueryNoLimit,
                                         sortDescriptors: nil) { (query, samples, error) in
                if let error = error {
                    // Handle the error here.
                    continuation.resume(throwing: error)
                }
                
                guard let ecgSamples = samples as? [HKElectrocardiogram] else {
                    continuation.resume(throwing: UpdateError.invalidSample)
                    return
                }
                
                continuation.resume(returning: ecgSamples)
            }
            
            // Execute the query.
            healthStore.execute(ecgQuery)
        }
        
        self.total = ECGSamples.count
        
        // MARK: - Obtain Samples
        for samples in ECGSamples {
            defer {
                self.current += 1
            }
            let destination: FinderItem = .documentsDirectory/"\(samples.startDate.description).csv"
            guard !destination.exists else { continue }
            
            let data = AsyncThrowingStream<(timeStamp: TimeInterval, value: HKQuantity?), any Error> { continuation in
                // Handle the samples here.
                // Create a query for the voltage measurements
                let voltageQuery = HKElectrocardiogramQuery(samples) { (query, result) in
                    switch(result) {
                    case .measurement(let measurement):
                        if let voltageQuantity = measurement.quantity(for: .appleWatchSimilarToLeadI) {
                            // Do something with the voltage quantity here.
                            
                            continuation.yield((measurement.timeSinceSampleStart, voltageQuantity))
                        }
                        
                    case .done:
                        // No more voltage measurements. Finish processing the existing measurements.
                        continuation.finish()
                        
                    case .error(let error):
                        // Handle the error here.
                        continuation.finish(throwing: error)
                        
                    @unknown default:
                        fatalError()
                    }
                }
                
                
                // Execute the query.
                healthStore.execute(voltageQuery)
            }
            
            // MARK: - Transform each sample to CSV
            var table = Tabular<TabularKeys>()
            for try await dataPoint in data {
                table.append { row in
                    row[.timeStamp] = String(dataPoint.timeStamp)
                    row[.value] = String(describing: dataPoint.value)
                }
            }
            try table.write(to: destination)
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
