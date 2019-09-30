////
////  NotificationService.swift
////  pushService
////
////  Created by igor on 9/11/19.
////  Copyright © 2019 The Chromium Authors. All rights reserved.
////
//
import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {

        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        if let userDefaults = UserDefaults(suiteName: "group.ua.liqpay") {
            let data: NSDictionary = bestAttemptContent?.userInfo["data"] as! NSDictionary
            let url = URL(string: "https://channelapi.dev.liqpay.ua/1.0/api/")!

            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            let json: [String: Any] = [
                "action": "ackPush",
                "reqId": "1496764112",
                "token": userDefaults.string(forKey: "token")!,
                "data": [
                    "channelId": data["channelId"] as! String,
                    "companyId": data["companyId"] as! String,
                    "baseMsgId": data["msgId"] as! String
                ]
            ]

            request.httpBody = try? JSONSerialization.data(withJSONObject: json)
            DispatchQueue.main.async {
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                    guard let data = data, error == nil else {
//                        return // check for fundamental networking error
//                    }
//                    let responseString = String(data: data, encoding: .utf8)
                }
                task.resume()
            }
        }

        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            bestAttemptContent.title = "\(bestAttemptContent.title) [modified YOS]"

            contentHandler(bestAttemptContent)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
