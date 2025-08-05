//
//  Coordinator.swift
//  ECGExport
//
//  Created by Vaida on 2025-08-05.
//

import SwiftUI
import HealthKit


@Observable
final class Coordinator: NSObject, HKLiveWorkoutBuilderDelegate {
    
    let watchCoordinator = WatchCoordinator.shared
    
    var heartRate: Double?
    
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        let date = Date()
        guard let statistics = workoutBuilder.statistics(for: HKObjectType.quantityType(forIdentifier: .heartRate)!) else { return }
        guard let bpm = statistics.mostRecentQuantity()?.doubleValue(for: .count().unitDivided(by: .minute())) else { return }
        DispatchQueue.main.async {
            self.heartRate = bpm
        }
        watchCoordinator.session.sendMessage(["heartRate": bpm, "date": date], replyHandler: nil)
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        
    }
    
    var session: HKWorkoutSession? // must keep reference
    var builder: HKLiveWorkoutBuilder?
    
    func startMonitor() async throws {
        let healthStore = HKHealthStore()
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]
        let types: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!
        ]
        try await healthStore.requestAuthorization(toShare: typesToShare, read: types)
        
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .walking
        configuration.locationType = .indoor
        
        self.session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        self.builder = session?.associatedWorkoutBuilder()
        
        builder?.delegate = self
        
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
        
        let startDate = Date()
        session?.startActivity(with: startDate)
        try await builder?.beginCollection(at: startDate)
    }
    
    
    static var shared = Coordinator()
    
}
