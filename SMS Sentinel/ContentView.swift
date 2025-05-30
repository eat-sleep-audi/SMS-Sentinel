//
//  ContentView.swift
//  SMS Sentinel
//
//  Created by Roosevelt B.  on 5/15/25.
//

import SwiftUI
import os

struct ContentView: View {
    @State private var messageText: String = ""
    @State private var predictionResult: String = ""
    @State private var showingReportAlert: Bool = false
    @StateObject private var spamStorage = SpamStorage()
    @StateObject private var settings = AppSettings()
    private let spamDetector = SpamDetector()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("SMS Sentinel")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                TextField("Enter SMS message", text: $messageText)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                Button(action: analyzeMessage) {
                    Text("Analyze")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                if !predictionResult.isEmpty {
                    Text(predictionResult)
                        .font(.title2)
                        .foregroundColor(predictionResult == "Flagged as Junk" ? .red : .green)
                        .padding()
                    
                    Button(action: {
                        showingReportAlert = true
                    }) {
                        Text("Report Incorrect")
                            .font(.subheadline)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .alert(isPresented: $showingReportAlert) {
                        Alert(
                            title: Text("Report Incorrect Prediction"),
                            message: Text("Reported: '\(messageText)' classified as '\(predictionResult)'"),
                            dismissButton: .default(Text("OK")) {
                                os_log("Reported: %@ classified as %@", log: AppLogger.contentView, type: .info, messageText, predictionResult)
                            }
                        )
                    }
                }
                
                Button(action: simulateSMS) {
                    Text("Simulate SMS")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                NavigationLink(destination: SpamFolderView(spamStorage: spamStorage)) {
                    Text("View Spam Folder")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                NavigationLink(destination: SettingsView(settings: settings)) {
                    Text("Settings")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .preferredColorScheme(settings.colorSchemeValue)
            .onAppear {
                os_log("ContentView loaded with colorScheme: %@", log: AppLogger.contentView, type: .debug, settings.colorScheme.rawValue)
            }
        }
    }
    
    private func analyzeMessage() {
        guard !messageText.isEmpty else {
            predictionResult = "Please enter a message"
            return
        }
        
        predictionResult = spamDetector.combinedPrediction(message: messageText)
        if predictionResult == "Flagged as Junk" {
            let message = SpamStorage.SpamMessage(
                id: UUID(),
                text: messageText,
                prediction: predictionResult,
                sender: "ManualTest",
                date: Date()
            )
            spamStorage.saveMessage(message)
        }
        os_log("Analyzed: %@ -> %@", log: AppLogger.contentView, type: .debug, messageText, predictionResult)
    }
    
    private func simulateSMS() {
        let testMessages = [
            "Test spam: Win $1000! Click here!",
            "Hey, let’s grab coffee later."
        ]
        for testMessage in testMessages {
            let result = spamDetector.combinedPrediction(message: testMessage)
            predictionResult = result
            if result == "Flagged as Junk" {
                let message = SpamStorage.SpamMessage(
                    id: UUID(),
                    text: testMessage,
                    prediction: result,
                    sender: "TestSender",
                    date: Date()
                )
                spamStorage.saveMessage(message)
            }
            os_log("Simulated: %@ -> %@", log: AppLogger.contentView, type: .debug, testMessage, result)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
