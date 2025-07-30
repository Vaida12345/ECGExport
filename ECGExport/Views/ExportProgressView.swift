//
//  ExportProgressView.swift
//  ECGExport
//
//  Created by Vaida on 2025-07-30.
//

import SwiftUI


struct ExportProgressView: View {
    
    @Bindable var coordinator: Coordinator
    @State private var position = ScrollPosition(idType: UUID.self)
    
    var body: some View {
        List {
            ForEach(coordinator.progress) { progress in
                VStack(alignment: .leading) {
                    HStack {
                        Label(progress.name, systemImage: progress.systemImage)
                            .labelStyle(.titleAndIcon)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Group {
                            switch progress.stage {
                            case .preparing: Text("Preparing")
                            case .finished: Text("Finished")
                            case .working: EmptyView()
                            }
                        }
                        .foregroundStyle(.secondary)
                        .padding(.trailing, 5)
                        .font(.callout)
                    }
                    
                    if progress.stage != .finished {
                        ProgressView(value: progress.fractionCompleted)
                            .progressViewStyle(.linear)
                            .padding(.vertical, 5)
                    }
                }
            }
        }
        .scrollDisabled(true)
        .scrollIndicators(.never)
        .scrollPosition($position, anchor: .bottom)
        .onChange(of: coordinator.progress) { oldValue, newValue in
            guard let id = newValue.last?.id else { return }
            position.scrollTo(id: id, anchor: .bottom)
        }
    }
    
}


#Preview {
    ExportProgressView(coordinator: .preview)
}

