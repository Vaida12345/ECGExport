//
//  Coordinator.swift
//  ECGExport
//
//  Created by Vaida on 3/22/25.
//

import Observation


@MainActor
@Observable
final class Coordinator {
    
    var current: Int = 0
    
    var total: Int? = nil
    
    
    func reset() {
        self.current = 0
        self.total = nil
    }
    
}
