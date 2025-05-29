//
//  InfoViewController.swift
//  MapApp
//
//  Created by Максим Байлюк on 27.05.2025.
//

import UIKit

class InfoViewController: UIViewController {
    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    var viewModel: InfoViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.bindLocationUpdates()
    }

    private func setupUI() {
        title = "Info"
        view.backgroundColor = .secondarySystemGroupedBackground
    }

    private func bindViewModel(completion: (() -> Void)? = nil) {
        viewModel.onInfoUpdate = { [weak self] coords, speed, distance in
            DispatchQueue.main.async {
                self?.coordinatesLabel.text = coords
                self?.speedLabel.text = speed
                self?.distanceLabel.text = distance
                completion?()
            }
        }
    }
}
