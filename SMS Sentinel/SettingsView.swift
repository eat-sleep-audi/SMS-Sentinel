//
//  SettingsView.swift
//  SMS Sentinel
//
//  Created by Roosevelt B. on 5/19/25.
//

import SwiftUI
import os

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    
    var body: some View {
        Form {
            Section(header: Text("Appearance")) {
                Picker("App Theme", selection: $settings.colorScheme) {
                    Text("System").tag(AppSettings.ColorScheme.system)
                    Text("Light").tag(AppSettings.ColorScheme.light)
                    Text("Dark").tag(AppSettings.ColorScheme.dark)
                }
                .pickerStyle(.segmented)
            }
            
            Section(header: Text("SMS Filtering")) {
                Text("Enable real-time spam filtering in Settings > Messages > Unknown & Spam > SMS Filtering > SMS Sentinel.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            os_log("SettingsView loaded with colorScheme: %@", log: AppLogger.settingsView, type: .debug, settings.colorScheme.rawValue)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView(settings: AppSettings())
        }
    }
}
