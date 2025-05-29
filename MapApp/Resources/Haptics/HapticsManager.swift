//
//  HapticsManager.swift
//  MapApp
//
//  Created by Максим Байлюк on 29.05.2025.
//
import AVKit
import Foundation

class HapticManager {

    static let shared = HapticManager()

    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
