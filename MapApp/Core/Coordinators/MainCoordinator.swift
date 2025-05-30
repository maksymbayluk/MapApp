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
    private var mainMapViewController: MainMapViewController?

    //Setting service and nav controller
    init(navigationController: UINavigationController, locationService: LocationService) {
        self.navigationController = navigationController
        self.locationService = locationService
    }
    
    //Turning on the location service and navigating to map
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
    //Selector for side menu
    func didSelectMenuOption(_ option: SideMenuOption) {
        let vc = makeViewController(for: option)
        containerVC.setContentViewController(vc)
    }
    //Selecting map to show route
    func selectMap() {
        guard let mainMapViewController = mainMapViewController else { return }
        containerVC.setContentViewController(mainMapViewController)
    }
}

extension MainCoordinator {
    //Factory of vc
    private func makeViewController(for option: SideMenuOption) -> UIViewController {
        switch option {
        case .map:
            let vm = MainMapViewModel(locationService: locationService)
            let vc = MainMapViewController(nibName: "MainMapViewController", bundle: nil)
            vc.viewModel = vm
            mainMapViewController = vc
            return vc

        case .list:
            let vc = PhotoListViewController()
            let service = PhotoNetworkService()
            let vm = PhotoListViewModel(service: service)
            vc.viewModel = vm
            return vc

        case .info:
            let vm = InfoViewModel(locationService: locationService)
            let vc = InfoViewController()
            vc.viewModel = vm
            vm.onRequestShowMapRoute = { [weak self] _ in
                guard
                    let self = self,
                    let mapVC = self.mainMapViewController else { return }
                if let polyline = CoreDataManager.shared.fetchRoutePolylineForLast(distance: 1000) {
                    DispatchQueue.main.async {
                        mapVC.polylineToDisplay = polyline
                        mapVC.drawRoutePolyline()
                        self.selectMap()
                    }
                }
            }
            return vc
        }
    }
}
