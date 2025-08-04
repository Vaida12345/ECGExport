//
//  WatchCoordinator.swift
//  ECGExport
//
//  Created by Vaida on 2025-08-04.
//

import Observation
import WatchConnectivity
import SwiftUI


@Observable
final class WatchCoordinator: NSObject, WCSessionDelegate {
    
    var sessionState: SessionState = .inactive
    
    var isReachable: Bool = false
    
    let session = WCSession.default
    
    var sessionError: (any Error)?
    
    var color: Color = .listAccessary
    
    
    override init() {
        super.init()
        self.session.delegate = self
    }
    
    
    func start() throws {
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
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard message.count == 3 else { return }
        guard let r = message["r"] as? Double, let g = message["g"] as? Double, let b = message["b"] as? Double else { return }
        let color = UIColor(red: r, green: g, blue: b, alpha: 1)
        self.color = Color(uiColor: color)
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        self.sessionState = .inactive
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        self.sessionState = .deactivated
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print(session)
        self.isReachable = session.isReachable
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        print(session.isPaired, session.isWatchAppInstalled)
    }
    
    
    enum SessionState {
        case inactive, deactivated, active
    }
    
}
