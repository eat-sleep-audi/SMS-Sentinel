//
//  AppSettings.swift
//  SMS Sentinel
//
//  Created by no use for a name on 5/19/25.
//

import SwiftUI
import os

class AppSettings: ObservableObject {
    enum ColorScheme: String, CaseIterable {
        case system, light, dark
    }
    
    @Published var colorScheme: ColorScheme {
        didSet {
            UserDefaults.standard.set(colorScheme.rawValue, forKey: "colorScheme")
        }
    }
    
    init() {
        let savedScheme = UserDefaults.standard.string(forKey: "colorScheme") ?? ColorScheme.system.rawValue
        self.colorScheme = ColorScheme(rawValue: savedScheme) ?? .system
        os_log("AppSettings initialized with colorScheme: %@", log: AppLogger.settingsView, type: .debug, colorScheme.rawValue)
    }
    
    var colorSchemeValue: SwiftUI.ColorScheme? {
        switch colorScheme {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
