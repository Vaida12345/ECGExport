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
    
    var sessionState: SessionState = .inactive
    
    var isReachable: Bool = false
    
    let session = WCSession.default
    
    var sessionError: (any Error)?
    
    
    override init() {
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
            self.sessionState = .active
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print(session)
        self.isReachable = session.isReachable
    }
    
    
    enum SessionState {
        case inactive, deactivated, active
    }
    
}
