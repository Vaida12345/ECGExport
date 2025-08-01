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
    
    var body: some Scene {
        WindowGroup {
            ContentView(coordinator: $coordinator)
                .background(Color.listBackground)
        }
    }
}
