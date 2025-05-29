//
//  NotificationService.swift
//  MapApp
//
//  Created by Максим Байлюк on 29.05.2025.
//

import CoreLocation
import UIKit
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { _, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }

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
