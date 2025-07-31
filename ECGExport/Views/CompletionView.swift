//
//  CompletionView.swift
//  ECGExport
//
//  Created by Vaida on 2025-07-31.
//

import SwiftUI


struct CompletionView: View {
    
    var body: some View {
        VStack {
            ContentUnavailableView("", systemImage: "checkmark")
            
            Text("Find the docs in Files > On My iPhone > ECGExport. [Learn More](https://github.com/Vaida12345/ECGExport)")
                .foregroundStyle(.secondary)
                .font(.caption)
        }
    }
    
}


#Preview {
    CompletionView()
}

