//
//  MainCoordinator.swift
//  MapApp
//
//  Created by Максим Байлюк on 27.05.2025.
//
import UIKit

// MARK: - MainCoordinator

class MainCoordinator: SideMenuContainerDelegate {

    private let navigationController: UINavigationController
    private var containerVC: SideMenuContainerViewController!
    private let locationService: LocationService

    init(navigationController: UINavigationController, locationService: LocationService) {
        self.navigationController = navigationController
        self.locationService = locationService
    }

    func start() {
        let mainMapVC = makeViewController(for: .map)
        let sideMenuVC = SideMenuViewController()
        let sideMenuVM = SideMenuViewModel()
        sideMenuVC.viewModel = sideMenuVM
        containerVC = SideMenuContainerViewController(mainMapViewController: mainMapVC as! MainMapViewController, sideMenuViewController: sideMenuVC)
        containerVC.delegate = self
        navigationController.setViewControllers([containerVC], animated: false)
        locationService.start()
    }

    func didSelectMenuOption(_ option: SideMenuOption) {
        let vc = makeViewController(for: option)
        containerVC.setContentViewController(vc)
    }
}

extension MainCoordinator {
    private func makeViewController(for option: SideMenuOption) -> UIViewController {
        switch option {
        case .map:
            let vm = MainMapViewModel(locationService: locationService)
            let vc = MainMapViewController()
            vc.viewModel = vm
            return vc

        case .list:
            return ListViewController()

        case .info:
            let vm = InfoViewModel(locationService: locationService)
            let vc = InfoViewController()
            vc.viewModel = vm
            return vc
        }
    }
}
