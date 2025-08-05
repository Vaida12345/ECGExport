//
//  Watch + Transfer.swift
//  ECGExport
//
//  Created by Vaida on 2025-08-05.
//

import CoreTransferable
import Essentials
import Tabular
import FinderItem


extension WatchCoordinator: Transferable {
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .commaSeparatedText) { coordinator in
            var table = Tabular<TabularKeys>()
            for entry in coordinator.data {
                table.append { row in
                    row[.date] = entry.1.ISO8601Format()
                    row[.heartRate] = entry.0.formatted(.number.precision(2))
                }
            }
            
            var text = ""
            table.write(to: &text)
            return text.data(using: .utf8)!
        }
    }
    
    enum TabularKeys: String, TabularKey {
        case date
        case heartRate = "Heart Rate (bpm)"
    }
    
}
