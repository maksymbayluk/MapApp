//
//  ViewController.swift
//  MapApp
//
//  Created by Максим Байлюк on 27.05.2025.
//

import MapKit
import UIKit

final class MainMapViewController: UIViewController {
    @IBOutlet weak var myLocation_btn: UIButton!
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
        setupUI()
        setUpMapView()
        bindViewModel()
    }

    private func setUpMapView() {
        mapView.showsUserLocation = true
        mapView.overrideUserInterfaceStyle = .dark
        mapView.setUserTrackingMode(.follow, animated: true)
        setCurrentLocation()
    }

    private func setupUI() {
        title = "Map"
        myLocation_btn.backgroundColor = .white
        myLocation_btn.setImage(UIImage(systemName: "location.fill"), for: .normal)
        myLocation_btn.layer.cornerRadius = myLocation_btn.bounds.width / 2
        myLocation_btn.layer.masksToBounds = true
        myLocation_btn.layer.shadowColor = UIColor.black.cgColor
        myLocation_btn.layer.shadowOpacity = 0.3
        myLocation_btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        myLocation_btn.layer.shadowRadius = 4
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
        viewModel?.centerUserLocation()
    }
}

