//
//  SpamDetector.swift
//  SMS Sentinel
//
//  Created by Roosevelt B. on 5/15/25.
//

import CoreML
import NaturalLanguage
import os

class SpamDetector {
    private let model: SMSSpamClassifier
    private let regexPatterns: [(pattern: String, regex: NSRegularExpression)]
    
    init() {
        let config = MLModelConfiguration()
        config.computeUnits = .cpuAndGPU
        guard let compiledModel = try? SMSSpamClassifier(configuration: config) else {
            fatalError("Failed to load NewSMSSpamClassifier model")
        }
        self.model = compiledModel
        
        let patterns = [
            "(?i)win.*\\$\\d+\\b",
            "https?://[^\\s]*(?:\\.co|\\.info|\\.xyz)",
            "(?i)free.*(gift|iphone)\\b",
            "(?i)usps.*track.*\\.(?:com|org)"
        ]
        self.regexPatterns = patterns.map { pattern in
            let regex = try! NSRegularExpression(pattern: pattern, options: [])
            return (pattern, regex)
        }
        os_log("SpamDetector initialized", log: AppLogger.spamDetector, type: .debug)
    }
    
    func isPotentialSpam(message: String) -> Bool {
        let nsMessage = message as NSString
        return regexPatterns.contains { (_, regex) in
            regex.firstMatch(in: message, options: [], range: NSRange(location: 0, length: nsMessage.length)) != nil
        }
    }
    
    func combinedPrediction(message: String) -> String {
        guard !message.isEmpty else {
            os_log("Empty message received", log: AppLogger.spamDetector, type: .info)
            return "Safe"
        }
        
        do {
            let prediction = try model.prediction(text: message)
            let label = prediction.label
            let ruleBased = isPotentialSpam(message: message)
            
            os_log("Prediction for '%@': ML=%@, Rules=%@", log: AppLogger.spamDetector, type: .debug, message, label, ruleBased.description)
            
            if label == "spam" || ruleBased {
                return "Flagged as Junk"
            }
            return "Safe"
        } catch {
            os_log("Prediction error: %@", log: AppLogger.spamDetector, type: .error, error.localizedDescription)
            return isPotentialSpam(message: message) ? "Flagged as Junk" : "Safe"
        }
    }
}
