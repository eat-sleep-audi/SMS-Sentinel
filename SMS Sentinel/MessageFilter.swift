//
//  MessageFilter.swift
//  SMS Sentinel
//
//  Created by Roosevelt B. on 5/15/25.
//

import IdentityLookup
import os

final class MessageFilter: NSObject, ILMessageFilterQueryHandling {
    private let spamDetector: SpamDetector
    private let spamStorage: SpamStorage
    
    override init() {
        self.spamDetector = SpamDetector()
        self.spamStorage = SpamStorage()
        super.init()
        os_log("MessageFilter initialized", log: AppLogger.messageFilter, type: .debug)
    }
    
    func handle(
        _ queryRequest: ILMessageFilterQueryRequest,
        context: ILMessageFilterExtensionContext,
        completion: @escaping (ILMessageFilterQueryResponse) -> Void
    ) {
        let response = ILMessageFilterQueryResponse()
        response.action = .allow
        
        let messageBody = queryRequest.messageBody ?? ""
        let sender = queryRequest.sender ?? "Unknown"
        
        os_log("Intercepted SMS from %@: %@", log: AppLogger.messageFilter, type: .debug, sender, messageBody)
        
        guard !messageBody.isEmpty else {
            os_log("Empty message body from %@", log: AppLogger.messageFilter, type: .info, sender)
            completion(response)
            return
        }
        
        let result = spamDetector.combinedPrediction(message: messageBody)
        
        switch result {
        case "Flagged as Junk":
            response.action = .filter
            os_log("Flagged as spam: %@ from %@", log: AppLogger.messageFilter, type: .info, messageBody, sender)
            let message = SpamStorage.SpamMessage(
                id: UUID(),
                text: messageBody,
                prediction: result,
                sender: sender,
                date: Date()
            )
            spamStorage.saveMessage(message)
        case "Safe":
            response.action = .allow
            os_log("Allowed: %@ from %@", log: AppLogger.messageFilter, type: .info, messageBody, sender)
        default:
            os_log("Prediction error: %@ for message: %@ from %@", log: AppLogger.messageFilter, type: .error, result, messageBody, sender)
            response.action = .allow
        }
        
        completion(response)
    }
}
