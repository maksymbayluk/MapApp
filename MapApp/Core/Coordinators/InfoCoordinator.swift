//
//  InfoCoordinator.swift
//  MapApp
//
//  Created by Максим Байлюк on 27.05.2025.
//
import UIKit


final class InfoCoordinator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let listVC = ListViewController()
        navigationController.pushViewController(listVC, animated: true)
    }
}
