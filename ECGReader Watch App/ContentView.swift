//
//  ContentView.swift
//  ECGReader Watch App
//
//  Created by Vaida on 2025-08-04.
//

import SwiftUI
import WatchConnectivity


struct ContentView: View {
    
    let watchCoordinator = WatchCoordinator()
    
    @State private var color: Color = .blue
    
    var body: some View {
        Rectangle()
            .fill(color)
            .ignoresSafeArea()
            .onAppear {
                watchCoordinator.start()
            }
            .onTapGesture {
                var color: Color = self.color
                while color == self.color {
                    color = [Color.blue, .green, .yellow, .red, .orange, .pink, .purple, .black, .white, .gray].randomElement()!
                }
                
                var r: CGFloat = 0
                var g: CGFloat = 0
                var b: CGFloat = 0
                UIColor(color).getRed(&r, green: &g, blue: &b, alpha: nil)
                
                watchCoordinator.session.sendMessage(["r": r, "g": g, "b": b], replyHandler: nil)
                self.color = color
            }
    }
}

#Preview {
    ContentView()
}
