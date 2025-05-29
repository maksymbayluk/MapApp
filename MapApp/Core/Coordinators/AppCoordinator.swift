//
//  AppCoordinator.swift
//  MapApp
//
//  Created by Максим Байлюк on 27.05.2025.
//
import UIKit

final class AppCoordinator {

    private let window: UIWindow
    private var mainCoordinator: MainCoordinator?

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let navController = UINavigationController()
        window.rootViewController = navController
        window.makeKeyAndVisible()
        let locationService = LocationService()
        locationService.requestAuthorization()

        mainCoordinator = MainCoordinator(navigationController: navController, locationService: locationService)
        mainCoordinator?.start()
    }
}
