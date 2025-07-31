//
//  Query + ECG.swift
//  ECGExport
//
//  Created by Vaida on 2025-07-30.
//

import HealthKit
import SwiftUI
import FinderItem
import Tabular


extension Coordinator {
    
    nonisolated func storeECG(from healthStore: HKHealthStore) async throws {
        let progress = await ExportProgress(name: "ECG", systemImage: "bolt.heart")
        await MainActor.run {
            withAnimation {
                self.progress.append(progress)
            }
        }
        
        let query = HKSampleQueryDescriptor(predicates: [.electrocardiogram()], sortDescriptors: [])
        let samples = try await query.result(for: healthStore)
        await MainActor.run {
            progress.totalCount = samples.count
        }
        
        let destFolder = FinderItem.documentsDirectory/progress.name
        try destFolder.makeDirectory()
        await MainActor.run {
            progress.stage = .working
        }
        
        for samples in samples {
            let itemFolder = destFolder/"\(Int(samples.startDate.timeIntervalSince1970))" // unix timestamp
            await MainActor.run { withAnimation { progress.completedCount += 1 } }
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
        
        await MainActor.run {
            withAnimation {
                progress.stage = .finished
            }
        }
    }
    
    
    private enum TabularKeys: String, TabularKey {
        case timeStamp
        case value
    }
}
