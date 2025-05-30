//
//  NotificationService.swift
//  MapApp
//
//  Created by Максим Байлюк on 29.05.2025.
//

import CoreLocation
import UIKit
import UserNotifications

//Singleton class that handles local notifications
final class NotificationService {
    static let shared = NotificationService()

    private init() {}
    //Requests basic notification permissions (alerts and sounds)
    func requestPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { _, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    //Creates customized notification content(notification with custom sound)
    func sendDistanceNotification(distance: CLLocationDistance) {
        let content = UNMutableNotificationContent()
        content.title = "Distance Update"
        content.sound = UNNotificationSound(named: UNNotificationSoundName("notification.wav"))
        content.body = "You've walked \(Int(distance)) meters!"

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
