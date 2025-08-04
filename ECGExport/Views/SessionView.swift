//
//  SessionView.swift
//  ECGExport
//
//  Created by Vaida on 2025-08-04.
//

import SwiftUI


struct SessionView: View {
    
    let watchCoordinator: WatchCoordinator
    
    var body: some View {
        switch watchCoordinator.sessionState {
        case .inactive:
            ContentUnavailableView("Session Inactive", systemImage: "pause.circle")
        case .deactivated:
            ContentUnavailableView("Session Deactivated", systemImage: "xmark.circle")
        case .active:
            if watchCoordinator.isReachable {
                watchCoordinator.color
                    .ignoresSafeArea()
            } else {
                ContentUnavailableView("Watch unreachable", systemImage: "antenna.radiowaves.left.and.right.slash")
            }
        }
    }
    
}


#Preview {
    SessionView(watchCoordinator: .init())
        .background(Color.listBackground)
}

