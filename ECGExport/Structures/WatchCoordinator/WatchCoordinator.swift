//
//  WatchCoordinator.swift
//  ECGExport
//
//  Created by Vaida on 2025-08-04.
//

import Observation
import WatchConnectivity
import SwiftUI
import OSLog


@Observable
final class WatchCoordinator: NSObject, WCSessionDelegate {
    
    var sessionState: SessionState = .inactive
    
    var isReachable: Bool = false
    
    let session = WCSession.default
    
    var sessionError: (any Error)?
    var sessionErrorIsPresented = false
    
    var data: [(Double, Date)] = []
    
    let logger = Logger(subsystem: "ECG Export", category: "WatchCoordinator")
    
    
    override init() {
        super.init()
        self.session.delegate = self
    }
    
    
    static func preview(data: [(Double, Date)] = []) -> WatchCoordinator {
        let coordinator = WatchCoordinator()
        coordinator.data = data
        coordinator.sessionState = .active
        return coordinator
    }
    
    
    func start() {
        self.session.activate()
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if let error {
            self.sessionError = error
            sessionErrorIsPresented = true
        } else {
            self.sessionState = .active
            self.isReachable = self.session.isReachable
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        logger.info("received: \(message)")
        guard message.count == 2 else { return }
        guard let heartRate = message["heartRate"] as? Double, let date = message["date"] as? Date else { return }
        self.data.insert((heartRate, date), at: 0)
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        self.sessionState = .inactive
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        self.sessionState = .deactivated
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        self.isReachable = session.isReachable
    }
    
    
    enum SessionState {
        case inactive, deactivated, active
    }
    
}
