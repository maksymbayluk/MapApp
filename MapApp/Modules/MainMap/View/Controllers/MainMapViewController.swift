//
//  ViewController.swift
//  MapApp
//
//  Created by Максим Байлюк on 27.05.2025.
//

import MapKit
import UIKit

// MARK: - MainMapViewController

final class MainMapViewController: UIViewController {
    @IBOutlet weak var myLocation_btn: UIButton!
    @IBOutlet weak var navigateTo_btn: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    var viewModel: MainMapViewModel?
    var didTapMenu: (() -> Void)?

    init() {
        super.init(nibName: "MainMapViewController", bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMapView()
        bindViewModel()
        setupUI()
    }

    private func setUpMapView() {
        mapView.showsUserLocation = true
        mapView.overrideUserInterfaceStyle = .dark
    }

    private func setupUI() {
        title = "Map"
        configureButton(myLocation_btn, imageName: "location.fill", color: .white)
        configureButton(navigateTo_btn, imageName: "arrow.triangle.turn.up.right.diamond.fill", color: .white)
        updateLocationDependentUI(status: LocationService.shared.authorizationStatus)
        LocationService.shared.onAuthorizationChanged = { [weak self] status in
            DispatchQueue.main.async {
                self?.updateLocationDependentUI(status: status)
            }
        }
    }

    private func setCurrentLocation() {
        if let coordinate = viewModel?.currentCoordinates {
            let region = MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
            )
            mapView.setRegion(region, animated: true)
        }
    }

    private func bindViewModel() {
        viewModel?.onUserLocationUpdated = { [weak self] coordinate in
            guard let self else { return }
            let region = MKCoordinateRegion(
                center: viewModel?.currentCoordinates ?? coordinate,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
            )
            self.mapView.setRegion(region, animated: true)
        }
        viewModel?.onLocationError = { _ in }
        viewModel?.didTapMenu = { [weak self] in
            self?.didTapMenu?()
        }
    }

    @objc private func sideMenuTapped() {
        viewModel?.didTapMenu?()
    }

    @IBAction func myLocationTapped(_: UIButton) {
        HapticManager.shared.impact(style: .heavy)
        viewModel?.centerUserLocation()
    }

    @IBAction func navigateToTapped(_: UIButton) {
        HapticManager.shared.impact(style: .heavy)
        NavigationService.shared.openNavigationToCityCenter()
    }
}

extension MainMapViewController {

    private func configureButton(_ button: UIButton, imageName: String, color: UIColor) {
        button.backgroundColor = color
        button.setImage(UIImage(systemName: imageName), for: .normal)
        button.layer.cornerRadius = button.bounds.width / 2
        button.layer.masksToBounds = true
    }

    func updateLocationDependentUI(status: CLAuthorizationStatus) {
        let isAuthorized = (status == .authorizedAlways || status == .authorizedWhenInUse)
        myLocation_btn.alpha = isAuthorized ? 1.0 : 0
        navigateTo_btn.alpha = isAuthorized ? 1.0 : 0
        if isAuthorized {
            mapView.setUserTrackingMode(.follow, animated: true)
            setCurrentLocation()
        }
    }
}

