//
//  ECGExportApp.swift
//  ECGExport
//
//  Created by Vaida on 3/21/25.
//

import SwiftUI

@main
struct ECGExportApp: App {
    
    @State private var coordinator = Coordinator()
    @State private var watchCoordinator = WatchCoordinator()
    
    var body: some Scene {
        WindowGroup {
            ContentView(coordinator: coordinator, watchCoordinator: watchCoordinator)
                .background(Color.listBackground)
        }
    }
}
