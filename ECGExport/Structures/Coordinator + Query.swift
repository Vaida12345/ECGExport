//
//  Coordinator + Query.swift
//  ECGExport
//
//  Created by Vaida on 2025-07-30.
//

import HealthKit
import FinderItem
import Tabular
import Essentials


extension Coordinator {
    
    func update() async throws {
        
        // MARK: - Ask for permission
        let healthStore = HKHealthStore()
        
        guard HKHealthStore.isHealthDataAvailable() else {
            throw UpdateError.noHealthData
        }
        
        let readTypes: Set<HKObjectType> = [ // FIXME: change the read types.
            HKObjectType.electrocardiogramType()
        ]
        
        try await healthStore.requestAuthorization(toShare: [], read: readTypes)
        
        
        try await self.storeECG(from: healthStore)
    }
    
    
    func storeECG(from healthStore: HKHealthStore) async throws {
        let query = HKSampleQueryDescriptor(predicates: [.electrocardiogram()], sortDescriptors: [])
        let samples = try await query.result(for: healthStore)
        self.total = samples.count
        
        let destFolder = FinderItem.documentsDirectory/"ECG"
        try destFolder.makeDirectory()
        
        for samples in samples {
            let itemFolder = destFolder/"\(Int(samples.startDate.timeIntervalSince1970))" // unix timestamp
            defer { self.current += 1 }
            guard !itemFolder.exists else { continue }
            
            try itemFolder.makeDirectory()
            
            let data = AsyncThrowingStream<(timeStamp: TimeInterval, value: HKQuantity?), any Error> { continuation in
                // Handle the samples here.
                // Create a query for the voltage measurements
                let voltageQuery = HKElectrocardiogramQuery(samples) { (query, result) in
                    switch(result) {
                    case .measurement(let measurement):
                        let voltageQuantity = measurement.quantity(for: .appleWatchSimilarToLeadI)
                        continuation.yield((measurement.timeSinceSampleStart, voltageQuantity))
                        
                    case .done:
                        continuation.finish()
                    case .error(let error):
                        continuation.finish(throwing: error)
                    @unknown default: fatalError()
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
                    row[.value] = dataPoint.value?.description ?? ""
                }
            }
            try table.write(to: itemFolder/"data.csv")
            
            // MARK: - Stores Metadata
            let metadata: [String: Any?] = [
                "startDate": samples.startDate.ISO8601Format(),
                "endDate": samples.endDate.ISO8601Format(),
                "hasUndeterminedDuration": samples.hasUndeterminedDuration,
                "classification": samples.classification.description,
                "averageHeartRate": samples.averageHeartRate?.doubleValue(for: .count().unitDivided(by: .minute())),
                "symptomsStatus": samples.symptomsStatus.description,
                "samplingFrequency": samples.samplingFrequency?.doubleValue(for: .hertz()),
                "AppleECGAlgorithmVersion": samples.metadata?[HKMetadataKeyAppleECGAlgorithmVersion],
                "source": "\(samples.sourceRevision.source.name) (\(samples.sourceRevision.source.bundleIdentifier))",
                "lead": "appleWatchSimilarToLeadI"
            ]
            try JSONSerialization.data(withJSONObject: metadata, options: [.prettyPrinted]).write(to: itemFolder/"metadata.json")
        }
    }
    
    
    enum TabularKeys: String, TabularKey {
        case timeStamp
        case value
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
