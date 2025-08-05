//
//  SessionView.swift
//  ECGExport
//
//  Created by Vaida on 2025-08-04.
//

import SwiftUI
import Essentials


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
                List {
                    ForEach(watchCoordinator.data, id: \.1) { (heartRate, date) in
                        HStack {
                            Text("\(heartRate, format: .number.precision(2)) bpm")
                            
                            Spacer()
                            
                            Text(date, format: .dateTime.hour().minute().second())
                                .font(.caption)
                        }
                    }
                }
            } else {
                ContentUnavailableView("Watch Unreachable", systemImage: "antenna.radiowaves.left.and.right.slash", description: Text("Please ensure the watch app is running, and that the watch is nearby."))
            }
        }
    }
    
}


#Preview {
    SessionView(watchCoordinator: .init())
        .background(Color.listBackground)
}

