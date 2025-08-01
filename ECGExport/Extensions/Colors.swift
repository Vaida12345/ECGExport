//
//  Colors.swift
//  ECGExport
//
//  Created by Vaida on 2025-08-01.
//

import SwiftUI


extension Color {
    /// Creates a context-dependent color with different values for light and dark appearances.
    ///
    /// - Parameters:
    ///   - light: The light appearance color value.
    ///   - dark: The dark appearance color value.
    public init(light: @autoclosure @escaping () -> Color, dark: @autoclosure @escaping () -> Color) {
#if os(watchOS)
        self = dark()
#elseif canImport(UIKit)
        self.init(
            uiColor: .init { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .unspecified, .light:
                    return UIColor(light())
                case .dark:
                    return UIColor(dark())
                @unknown default:
                    return UIColor(light())
                }
            }
        )
#elseif canImport(AppKit)
        self.init(
            nsColor: .init(name: nil) { appearance in
                if appearance.bestMatch(from: [.aqua, .darkAqua]) == .aqua {
                    return NSColor(light())
                } else {
                    return NSColor(dark())
                }
            }
        )
#endif
    }
}


extension Color {
    
    static let listBackground = Color(light: Color(red: 242 / 255, green: 242 / 255, blue: 247 / 255), dark: .black)
    
    static let listAccessary = Color(light: .white, dark: Color(red: 28 / 255, green: 28 / 255, blue: 30 / 255))
    
}
