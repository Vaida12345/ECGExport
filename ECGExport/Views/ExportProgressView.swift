//
//  ExportProgressView.swift
//  ECGExport
//
//  Created by Vaida on 2025-07-30.
//

import SwiftUI


struct ExportProgressView: View {
    
    let progresses: [ExportProgress]
    @State private var position = ScrollPosition(idType: UUID.self)
    
    var body: some View {
        List {
            ForEach(progresses) { progress in
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
                    
                    ProgressView(value: progress.fractionCompleted)
                        .progressViewStyle(.linear)
                        .padding(.vertical, 5)
                        .tint(progress.stage == .finished ? AnyShapeStyle(.secondary.opacity(0.5)) : AnyShapeStyle(Color.accentColor))
                }
            }
        }
        .scrollDisabled(true)
        .scrollIndicators(.never)
        .scrollPosition($position, anchor: .bottom)
        .onChange(of: progresses) { oldValue, newValue in
            guard let id = newValue.last?.id else { return }
            position.scrollTo(id: id, anchor: .bottom)
        }
    }
    
}


#Preview {
    @Previewable @State var progress = ExportProgress(name: "123", systemImage: "pencil", completedCount: 10, totalCount: 10)
    
    var isFinished: Binding<Bool> {
        Binding<Bool> {
            progress.stage == .finished
        } set: { newValue in
            withAnimation {
                progress.stage = newValue ? .finished : .working
            }
        }
    }
    
    ExportProgressView(progresses: [progress])
        .overlay(alignment: .bottom) {
            Toggle("finish", isOn: isFinished)
                .padding()
        }
}

