//
//  Logging.swift
//  SMS Sentinel
//
//  Created by Roosevelt B.  on 5/19/25.
//

import os

struct AppLogger {
    static let subsystem = "com.yourcompany.SMSSentinel"
    static let contentView = OSLog(subsystem: subsystem, category: "ContentView")
    static let settingsView = OSLog(subsystem: subsystem, category: "SettingsView")
    static let spamDetector = OSLog(subsystem: subsystem, category: "SpamDetector")
    static let messageFilter = OSLog(subsystem: subsystem, category: "MessageFilter")
    static let spamStorage = OSLog(subsystem: subsystem, category: "SpamStorage")
    static let spamFolderView = OSLog(subsystem: subsystem, category: "SpamFolderView")
}
