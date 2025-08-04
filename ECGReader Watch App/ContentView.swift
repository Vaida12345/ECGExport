//
//  ContentView.swift
//  ECGReader Watch App
//
//  Created by Vaida on 2025-08-04.
//

import SwiftUI
import WatchConnectivity


struct ContentView: View {
    
    let watchCoordinator: WatchCoordinator
    
    @State private var color: Color = .blue
    
    var body: some View {
        if watchCoordinator.isReachable {
            Rectangle()
                .fill(color)
                .ignoresSafeArea()
                .onTapGesture {
                    var color: Color = self.color
                    while color == self.color {
                        color = [Color.blue, .green, .yellow, .red, .orange, .pink, .purple, .black, .white, .gray].randomElement()!
                    }
                    
                    var r: CGFloat = 0
                    var g: CGFloat = 0
                    var b: CGFloat = 0
                    UIColor(color).getRed(&r, green: &g, blue: &b, alpha: nil)
                    
                    let date = Date()
                    
                    watchCoordinator.session.sendMessage(["r": r, "g": g, "b": b, "date": date], replyHandler: nil)
                    self.color = color
                }
        } else {
            ContentUnavailableView("Phone Unreachable", systemImage: "antenna.radiowaves.left.and.right.slash")
        }
    }
}

#Preview {
    ContentView(watchCoordinator: .init())
}
