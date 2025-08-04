//
//  SelectionCell.swift
//  ECGExport
//
//  Created by Vaida on 2025-08-04.
//

import SwiftUI


struct SelectionCell: View {
    
    @Binding var operation: OperationType
    
    let tag: OperationType
    
    
    var body: some View {
        Button {
            withAnimation {
                operation = tag
            }
        } label: {
            HStack {
                Image(systemName: tag.systemName)
                    .imageScale(.large)
                    .fontWeight(.medium)
                    .padding(7)
                    .foregroundStyle(operation == tag ? .blue : .primary)
                
                VStack(alignment: .leading) {
                    Text(tag.name)
                        .fontWeight(.medium)
                    
                    Text(tag.description)
                        .multilineTextAlignment(.leading)
                        .font(.caption)
                }
            }
        }
        .buttonStyle(.plain)
        .padding()
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 21)
                .stroke(operation == tag ? .blue : .gray, lineWidth: operation == tag ? 4 : 2)
                .fill(Color.listAccessary.mix(with: .blue, by: operation == tag ? 0.1 : 0))
        }
        .padding([.horizontal, .top])
    }
    
}


#Preview {
    @Previewable @State var operation = OperationType.export
    
    SelectionCell(operation: $operation, tag: .export)
}

