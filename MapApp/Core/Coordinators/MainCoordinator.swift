//
//  MainCoordinator.swift
//  MapApp
//
//  Created by Максим Байлюк on 27.05.2025.
//
import UIKit

final class MainCoordinator: SideMenuContainerDelegate {

    private let navigationController: UINavigationController
    private var containerVC: SideMenuContainerViewController!


    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let mainMapVM = MainMapViewModel()
        let mainMapVC = MainMapViewController()
        let sideMenuVC = SideMenuViewController()
        let sideMenuVM = SideMenuViewModel()
        sideMenuVC.viewModel = sideMenuVM
        mainMapVC.viewModel = mainMapVM
        containerVC = SideMenuContainerViewController(mainMapViewController: mainMapVC, sideMenuViewController: sideMenuVC)
        containerVC.delegate = self
        navigationController.setViewControllers([containerVC], animated: false)
    }

    func didSelectMenuOption(_ option: SideMenuOption) {
        switch option {
        case .map:
            let mapVC = MainMapViewController()
            mapVC.viewModel = MainMapViewModel()
            containerVC.setContentViewController(mapVC)

        case .list:
            let listVC = ListViewController()
            containerVC.setContentViewController(listVC)

        case .info:
            let infoVC = InfoViewController()
            containerVC.setContentViewController(infoVC)
        }
    }
}
