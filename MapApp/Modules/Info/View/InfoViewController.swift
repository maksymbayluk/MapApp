//
//  InfoViewController.swift
//  MapApp
//
//  Created by Максим Байлюк on 27.05.2025.
//

import UIKit

//view controller that displays location tracking information and provides navigation functionality
class InfoViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var showLastKm_button: UIButton!
    var viewModel: InfoViewModel!
    //Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.bindLocationUpdates()
    }
    //Configures scroll view behavior and title
    private func setupUI() {
        scrollView.contentInsetAdjustmentBehavior = .always
        title = "Info"
    }
    //Establishes callback for info updates, updates all labels on main thread, manages route button state based on distance
    private func bindViewModel(completion: (() -> Void)? = nil) {
        viewModel.onInfoUpdate = { [weak self] coords, speed, distance in
            DispatchQueue.main.async {
                self?.coordinatesLabel.text = coords
                self?.speedLabel.text = speed
                self?.distanceLabel.text = distance
                if distance.contains("km") {
                    self?.showRouteButton(enabled: true)
                } else {
                    self?.showRouteButton(enabled: false)
                }
                completion?()
            }
        }
    }
    //Delegates route display to view model(show map with route)
    @IBAction func showRouteButtonTapped(_: UIButton) {
        viewModel.showMapWithRoute()
    }
    //Sets the button state
    func showRouteButton(enabled: Bool) {
        showLastKm_button.isEnabled = enabled
        showLastKm_button.alpha = enabled ? 1 : 0.5
    }
}
