//
//  SideMenuViewController.swift
//  MapApp
//
//  Created by Максим Байлюк on 27.05.2025.
//

import UIKit

// MARK: - SideMenuContainerDelegate

protocol SideMenuContainerDelegate: AnyObject {
    func didSelectMenuOption(_ option: SideMenuOption)
}

// MARK: - SideMenuViewController

class SideMenuViewController: UIViewController {
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var table_view_height: NSLayoutConstraint!
    var viewModel: SideMenuViewModel!

    init() {
        super.init(nibName: "SideMenuViewController", bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.removeObserver(self, forKeyPath: "contentSize")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            if let tbl = object as? UITableView, tbl == tableView, let newValue = change?[.newKey] as? CGSize {
                table_view_height.constant = newValue.height
                preferredContentSize = CGSize(width: view.frame.width, height: newValue.height)
            }
        }
    }

    private func setupUI() {
        titleLabel.text = "My app helps users navigate, explore new locations, track their routes, and discover interesting places with interactive, real-time maps"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "side_menu_cell")
        tableView.isScrollEnabled = false
        tableView.reloadData()
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension SideMenuViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = viewModel.options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "side_menu_cell", for: indexPath)
        cell.textLabel?.text = option.title
        cell.imageView?.image = UIImage(systemName: option.iconName)
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectOption(at: indexPath.row)
    }
}
