//
//  Descriptions.swift
//  ECGExport
//
//  Created by Vaida on 2025-07-30.
//

import HealthKit


extension HKElectrocardiogram.Classification: @retroactive CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .notSet: "notSet"
        case .sinusRhythm: "sinusRhythm"
        case .atrialFibrillation: "atrialFibrillation"
        case .inconclusiveLowHeartRate: "inconclusiveLowHeartRate"
        case .inconclusiveHighHeartRate: "inconclusiveHighHeartRate"
        case .inconclusivePoorReading: "inconclusivePoorReading"
        case .inconclusiveOther: "inconclusiveOther"
        case .unrecognized: "unrecognized"
        @unknown default: self.rawValue.description
        }
    }
    
}


extension HKElectrocardiogram.SymptomsStatus: @retroactive CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .notSet: "notSet"
        case .none: "none"
        case .present: "present"
        @unknown default: self.rawValue.description
        }
    }
    
}
