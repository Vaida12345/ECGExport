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
            
            let data = HKElectrocardiogramQueryDescriptor(samples).results(for: healthStore)
            
            // MARK: - Transform each sample to CSV
            var table = Tabular<TabularKeys>()
            for try await dataPoint in data {
                table.append { row in
                    row[.timeStamp] = String(dataPoint.timeSinceSampleStart)
                    row[.value] = dataPoint.quantity(for: .appleWatchSimilarToLeadI)?.doubleValue(for: .voltUnit(with: .micro)).description ?? ""
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
        case value = "value (mcV)"
    }
}
