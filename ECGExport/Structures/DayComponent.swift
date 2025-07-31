//
//  DayComponent.swift
//  ECGExport
//
//  Created by Vaida on 2025-07-31.
//


struct DayComponent: Hashable, CustomStringConvertible {
    
    let year: Int
    
    let month: Int
    
    let day: Int
    
    
    var description: String {
        "\(self.year)-\(self.month)-\(self.day)"
    }
    
}
