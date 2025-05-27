//
//  InfoViewController.swift
//  MapApp
//
//  Created by Максим Байлюк on 27.05.2025.
//

import UIKit

class InfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = "Info"
        view.backgroundColor = .secondarySystemGroupedBackground
    }
}
