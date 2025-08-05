//
//  WatchCoordinator.swift
//  ECGExport
//
//  Created by Vaida on 2025-08-04.
//


import Observation
import WatchConnectivity


@Observable
final class WatchCoordinator: NSObject, WCSessionDelegate {
    
    var isReachable: Bool = false
    
    let session = WCSession.default
    
    var sessionError: (any Error)?
    
    
    private override init() {
        super.init()
        self.session.delegate = self
    }
    
    
    func start() {
        self.session.activate()
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if let error {
            print(error)
            self.sessionError = error
        } else {
            self.isReachable = self.session.isReachable
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        self.isReachable = session.isReachable
    }
    
    
    static let shared = WatchCoordinator()
    
}
