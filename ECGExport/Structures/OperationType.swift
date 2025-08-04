//
//  OperationType.swift
//  ECGExport
//
//  Created by Vaida on 2025-08-04.
//


enum OperationType {
    case export
    case monitor
    
    
    var systemName: String {
        switch self {
        case .export:
            return "tray.and.arrow.up"
        case .monitor:
            return "inset.filled.rectangle.and.person.filled"
        }
    }
    
    var name: String {
        switch self {
        case .export:
            "Export Health Data"
        case .monitor:
            "Monitor Health Data"
        }
    }
    
    var verb: String {
        switch self {
        case .export: "Export"
        case .monitor: "Monitor"
        }
    }
    
    var description: String {
        switch self {
        case .export:
            "Export your history of heart rate and other health data to Files app"
        case .monitor:
            "Monitor your heart rate and other health data in real time using your Apple Watch"
        }
    }
}
