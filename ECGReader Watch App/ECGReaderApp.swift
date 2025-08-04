//
//  ECGReaderApp.swift
//  ECGReader Watch App
//
//  Created by Vaida on 2025-08-04.
//

import SwiftUI

@main
struct ECGReader_Watch_AppApp: App {
    
    let watchCoordinator = WatchCoordinator()
    
    
    var body: some Scene {
        WindowGroup {
            ContentView(watchCoordinator: watchCoordinator)
        }
    }
    
    init() {
        watchCoordinator.start()
    }
}
