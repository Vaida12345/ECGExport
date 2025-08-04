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
    
    nonisolated func storeQuantity(
        from healthStore: HKHealthStore,
        name: String, systemImage: String,
        identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        additionalNames: [String] = [],
        updateRow: (_ row: inout Tabular<QuantityTabularKeys>.Row, _ sample: HKQuantitySample) -> Void = { _, _ in }
    ) async throws {
        let progress = await ExportProgress(name: name, systemImage: systemImage)
        await MainActor.run {
            withAnimation {
                self.progress.append(progress)
            }
        }
        
        let query = HKSampleQueryDescriptor(predicates: [.quantitySample(type: HKQuantityType(identifier))], sortDescriptors: [])
        let samples = try await query.result(for: healthStore)
        
        let destFolder = FinderItem.documentsDirectory/progress.name
        try destFolder.makeDirectory()
        await MainActor.run {
            progress.stage = .working
        }
        
        let aggregated = samples.reduce(into: [DateComponents: [HKQuantitySample]]()) { result, sample in
            let date = Calendar.current.dateComponents([.year, .month, .day], from: sample.startDate)
            result[date, default: []].append(sample)
        }
        let currentComponent = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        await MainActor.run {
            progress.totalCount = aggregated.count
        }
        
        for (component, samples) in aggregated {
            let dest = destFolder/"\(component.year ?? 0)-\(component.month ?? 0)-\(component.day ?? 0).csv"
            await MainActor.run { withAnimation { progress.completedCount += 1 } }
            if component == currentComponent {
                try dest.removeIfExists() // always updates today
            }
            
            guard !dest.exists else { continue }
            
            // MARK: - Transform each sample to CSV
            var table = Tabular<QuantityTabularKeys>()
            for (index, dataPoint) in samples.enumerated() {
                let quantityType = HKQuantityType(identifier)
                let objectPredicate = HKQuery.predicateForObject(with: dataPoint.uuid)
                let predicate = HKSamplePredicate.quantitySample(type: quantityType, predicate: objectPredicate)
                
                let seriesDescriptor = HKQuantitySeriesSampleQueryDescriptor(predicate: predicate, options: [.orderByQuantitySampleStartDate, .includeSample])
                let series = seriesDescriptor.results(for: healthStore)
                
                // Access each data entry in the series
                for try await entry in series {
                    table.append { row in
                        row[.startDate] = entry.dateInterval.start.ISO8601Format()
                        row[.endDate] = entry.dateInterval.end.ISO8601Format()
                        row[.value] = String(entry.quantity.doubleValue(for: unit))
                        row[.aggregationStyle] = entry.sample!.quantityType.aggregationStyle.description
                        updateRow(&row, entry.sample!)
                        row[.source] = "\(entry.sample!.sourceRevision.source.name) (\(entry.sample!.sourceRevision.source.bundleIdentifier))"
                        row[.groupIndex] = index.description
                    }
                }
            }
            
            try table.write(cases: QuantityTabularKeys.allCases + additionalNames.map({ QuantityTabularKeys.custom($0) }), to: dest)
        }
        
        await MainActor.run {
            progress.stage = .finished
        }
    }
    
    
    enum QuantityTabularKeys: RawRepresentable, TabularKey {
        case startDate
        case endDate
        case value
        case aggregationStyle
        case source
        case groupIndex
        case custom(String)
        
        static var allCases: [Coordinator.QuantityTabularKeys] {
            [.startDate, .endDate, .value, .aggregationStyle, .source, .groupIndex]
        }
        
        var rawValue: String {
            switch self {
            case .startDate: return "startDate"
            case .endDate: return "endDate"
            case .value: return "value"
            case .aggregationStyle: return "aggregationStyle"
            case .source: return "source"
            case .groupIndex: return "groupIndex"
            case .custom(let value): return value
            }
        }
        
        init?(rawValue: String) {
            switch rawValue {
            case "startDate": self = .startDate
            case "endDate": self = .endDate
            case "value": self = .value
            case "aggregationStyle": self = .aggregationStyle
            case "source": self = .source
            case "groupIndex": self = .groupIndex
            default: self = .custom(rawValue)
            }
        }
    }
}
