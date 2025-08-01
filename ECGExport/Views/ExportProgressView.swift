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
        ScrollView {
            ForEach(progresses) { progress in
                Section {
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
                .padding()
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .background {
                    RoundedRectangle(cornerRadius: 21)
                        .fill(.background)
                        .shadow(color: .black.opacity(0.15), radius: 5)
                }
                .padding([.horizontal, .top])
            }
            .scrollTargetLayout()
        }
        .scrollDisabled(true)
        .scrollIndicators(.never)
        .scrollPosition($position, anchor: .top)
        .animation(.easeInOut, value: progresses)
        .onChange(of: progresses) { oldValue, newValue in
            guard let id = newValue.last?.id else { return }
            withAnimation {
                position.scrollTo(id: id, anchor: .top)
            }
        }
    }
    
}


#Preview {
    @Previewable @State var insertNew = false
    @Previewable @State var progress = ExportProgress(name: "123", systemImage: "pencil", completedCount: 10, totalCount: 10)
    
    let new = ExportProgress(name: "456", systemImage: "pencil")
    
    var isFinished: Binding<Bool> {
        Binding<Bool> {
            progress.stage == .finished
        } set: { newValue in
            withAnimation {
                progress.stage = newValue ? .finished : .working
            }
        }
    }
    
    ExportProgressView(progresses: [progress] + (insertNew ? [new] : []))
        .overlay(alignment: .bottom) {
            VStack {
                Toggle("finish", isOn: isFinished)
                
                Toggle("new", isOn: $insertNew.animation())
            }
            .padding()
        }
}

