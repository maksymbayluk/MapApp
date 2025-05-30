//
//  ViewController.swift
//  MapApp
//
//  Created by Максим Байлюк on 27.05.2025.
//

import MapKit
import UIKit

//class that shows map, handles user location, and do UI updates(buttons)
final class MainMapViewController: UIViewController {
    //Button for centering the map on the user's current location
    @IBOutlet weak var myLocation_btn: UIButton!
    //Button for triggering navigation to a predefined destination
    @IBOutlet weak var navigateTo_btn: UIButton!
    //map
    @IBOutlet weak var mapView: MKMapView!
    //Optional polyline to render a route on the map
    var polylineToDisplay: MKPolyline?
    //ViewModel providing location data and actions
    var viewModel: MainMapViewModel?
    //Closure that gets called when the side menu is triggered
    var didTapMenu: (() -> Void)?

    //lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMapView()
        bindViewModel()
        setupUI()
    }
    //Sets the map delegate and appearance
    private func setUpMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.overrideUserInterfaceStyle = .dark
    }
    //setting UI, configures the appearance of buttons, sets a listener for location authorization changes
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
    //Centers the map on the user current coordinates if available
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
    //Binds to the ViewModel callbacks
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
    //invokes the didTapMenu closure
    @objc private func sideMenuTapped() {
        viewModel?.didTapMenu?()
    }
    //center button tapped
    @IBAction func myLocationTapped(_: UIButton) {
        HapticManager.shared.impact(style: .heavy)
        viewModel?.centerUserLocation()
    }
    //navigate to city center button tapped
    @IBAction func navigateToTapped(_: UIButton) {
        HapticManager.shared.impact(style: .heavy)
        NavigationService.shared.openNavigationToCityCenter()
    }
}

extension MainMapViewController {
    //setting the appearance of the button
    private func configureButton(_ button: UIButton, imageName: String, color: UIColor) {
        button.backgroundColor = color
        button.setImage(UIImage(systemName: imageName), for: .normal)
        button.layer.cornerRadius = button.bounds.width / 2
        button.layer.masksToBounds = true
    }
    //shows or hides buttons based on authorization
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

extension MainMapViewController: MKMapViewDelegate {
    //renders a polyline on the map
    func mapView(_: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 4
            return renderer
        }
        return MKOverlayRenderer()
    }
}

extension MainMapViewController {
    //removes existing polyline and adds the new polyline
    func drawRoutePolyline() {
        guard let polyline = polylineToDisplay else { return }
        DispatchQueue.main.async {
            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.addOverlay(polyline)
            self.mapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40), animated: true)
        }
    }
}

