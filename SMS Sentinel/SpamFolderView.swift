//
//  SpamFolderView.swift
//  SMS Sentinel
//
//  Created by Roosevelt B. on 5/19/25.
//

import SwiftUI
import os

struct SpamFolderView: View {
    @ObservedObject var spamStorage: SpamStorage
    
    var body: some View {
        List {
            if spamStorage.messages.isEmpty {
                Text("No spam messages")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ForEach(spamStorage.messages, id: \.id) { message in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("From: \(message.sender)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(message.text)
                            .font(.body)
                        Text("Flagged: \(message.prediction)")
                            .font(.caption)
                        Text("Date: \(message.date, style: .date)")
                            .font(.caption)
                        Button(action: {
                            spamStorage.messages.removeAll { $0.id == message.id }
                            spamStorage.saveToStorage() // Ensure changes persist
                            os_log("Marked as not spam: %@ from %@", log: AppLogger.spamFolderView, type: .info, message.text, message.sender)
                        }) {
                            Text("Mark as Not Spam")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Spam Folder")
        .onAppear {
            os_log("SpamFolderView loaded with %d messages", log: AppLogger.spamFolderView, type: .debug, spamStorage.messages.count)
        }
    }
}

struct SpamFolderView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SpamFolderView(spamStorage: SpamStorage())
        }
    }
}
