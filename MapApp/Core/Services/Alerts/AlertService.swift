//
//  AlertService.swift
//  MapApp
//
//  Created by Максим Байлюк on 29.05.2025.
//

import UIKit

enum AlertService {

    static func showAlert(
        title: String,
        message: String,
        actions: [UIAlertAction] = [UIAlertAction(title: "OK", style: .default)],
        in viewController: UIViewController? = topViewController()
    ) {
        guard let viewController = viewController else {
            return
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }

        DispatchQueue.main.async {
            viewController.present(alert, animated: true)
        }
    }

    // MARK: - Helper to find top most view controller
    private static func topViewController(
        _ rootViewController: UIViewController? = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
    ) -> UIViewController? {
        if let navigationController = rootViewController as? UINavigationController {
            return topViewController(navigationController.visibleViewController)
        }
        if let tabBarController = rootViewController as? UITabBarController {
            return topViewController(tabBarController.selectedViewController)
        }
        if let presented = rootViewController?.presentedViewController {
            return topViewController(presented)
        }
        return rootViewController
    }
}
