//
//  SpamStorage.swift
//  SMS Sentinel
//
//  Created by no use for a name on 5/16/25.
//

// SpamStorage.swift
import Foundation
import os

class SpamStorage: ObservableObject {
    @Published var messages: [SpamMessage] = []
    
    struct SpamMessage: Identifiable, Codable {
        let id: UUID
        let text: String
        let prediction: String
        let sender: String
        let date: Date
    }
    
    func saveMessage(_ message: SpamMessage) {
        DispatchQueue.main.async {
            self.messages.append(message)
            self.saveToStorage()
            os_log("Saved spam: %@ from %@", log: AppLogger.spamStorage, type: .info, message.text, message.sender)
        }
    }
    
    func saveToStorage() {
        if let data = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(data, forKey: "spamMessages")
            os_log("Saved %d messages to storage", log: AppLogger.spamStorage, type: .debug, messages.count)
        }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "spamMessages"),
           let savedMessages = try? JSONDecoder().decode([SpamMessage].self, from: data) {
            self.messages = savedMessages
        }
        os_log("SpamStorage initialized with %d messages", log: AppLogger.spamStorage, type: .debug, messages.count)
    }
}
