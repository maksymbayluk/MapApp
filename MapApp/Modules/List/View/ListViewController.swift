//
//  ListViewController.swift
//  MapApp
//
//  Created by Максим Байлюк on 27.05.2025.
//
import UIKit


final class ListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = "List"
        view.backgroundColor = .secondarySystemGroupedBackground
    }
}

