//
//  Query + Quantity.swift
//  ECGExport
//
//  Created by Vaida on 2025-07-30.
//

import HealthKit
import SwiftUI
import FinderItem
import Tabular


extension Coordinator {
    
    nonisolated func storeHeartRate(
        from healthStore: HKHealthStore
    ) async throws {
        let progress = await ExportProgress(name: "Heart Rate", systemImage: "heart.fill")
        await MainActor.run {
            withAnimation {
                self.progress.append(progress)
            }
        }
        
        let query = HKSampleQueryDescriptor(predicates: [.quantitySample(type: HKQuantityType(.heartRate))], sortDescriptors: [])
        let samples = try await query.result(for: healthStore)
        
        let destFolder = FinderItem.documentsDirectory/progress.name
        try destFolder.makeDirectory()
        await MainActor.run {
            progress.stage = .working
        }
        
        let aggregated = samples.reduce(into: [DayComponent: [HKQuantitySample]]()) { result, sample in
            let date = Calendar.current.dateComponents([.year, .month, .day], from: sample.startDate)
            result[DayComponent(year: date.year!, month: date.month!, day: date.day!), default: []].append(sample)
        }
        await MainActor.run {
            progress.totalCount = aggregated.count
        }
        
        for (component, samples) in aggregated {
            let dest = destFolder/"\(component).csv"
            await MainActor.run { withAnimation { progress.completedCount += 1 } }
            
            guard !dest.exists else { continue }
            
            // MARK: - Transform each sample to CSV
            var table = Tabular<TabularKeys>()
            for (index, dataPoint) in samples.enumerated() {
                let heartRate = HKQuantityType(.heartRate)
                let objectPredicate = HKQuery.predicateForObject(with: dataPoint.uuid)
                let predicate = HKSamplePredicate.quantitySample(type: heartRate, predicate: objectPredicate)
                
                let seriesDescriptor = HKQuantitySeriesSampleQueryDescriptor(predicate: predicate, options: [.orderByQuantitySampleStartDate, .includeSample])
                let series = seriesDescriptor.results(for: healthStore)
                
                
                // Access each data entry in the series
                for try await entry in series {
                    table.append { row in
                        row[.startDate] = entry.dateInterval.start.ISO8601Format()
                        row[.endDate] = entry.dateInterval.end.ISO8601Format()
                        row[.value] = String(entry.quantity.doubleValue(for: .count().unitDivided(by: .minute())))
                        row[.aggregationStyle] = entry.sample!.quantityType.aggregationStyle.description
                        row[.motionContext] = (entry.sample!.metadata?[HKMetadataKeyHeartRateMotionContext] as? NSNumber).flatMap({ HKHeartRateMotionContext(rawValue: $0.intValue)?.description }) ?? ""
                        row[.source] = "\(entry.sample!.sourceRevision.source.name) (\(entry.sample!.sourceRevision.source.bundleIdentifier))"
                        row[.groupIndex] = index.description
                    }
                }
            }
            
            try table.write(to: dest)
        }
        
        await MainActor.run {
            progress.stage = .finished
        }
    }
    
    
    private enum TabularKeys: String, TabularKey {
        case startDate
        case endDate
        case value
        case aggregationStyle
        case motionContext
        case source
        case groupIndex
    }
}
