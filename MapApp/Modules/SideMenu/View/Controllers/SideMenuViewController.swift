//
//  SideMenuViewController.swift
//  MapApp
//
//  Created by Максим Байлюк on 27.05.2025.
//

import UIKit

// MARK: - SideMenuContainerDelegate
//protocol fo
protocol SideMenuContainerDelegate: AnyObject {
    func didSelectMenuOption(_ option: SideMenuOption)
}

// MARK: - SideMenuViewController
//class designed to display a side menu list
class SideMenuViewController: UIViewController {
    //holds the logo image, styled with shadows and rounded corners
    @IBOutlet weak var logoImageContainer: UIView!
    //Displays a circular logo image
    @IBOutlet weak var logoImageView: UIImageView!
    //Shows a text about the app
    @IBOutlet weak var titleLabel: UILabel!
    //Lists the menu options
    @IBOutlet weak var tableView: UITableView!
    //constaint to adjust the height of the tv based on content
    @IBOutlet weak var table_view_height: NSLayoutConstraint!
    //supplies the menu options
    var viewModel: SideMenuViewModel!

    init() {
        super.init(nibName: "SideMenuViewController", bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setLogo()
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
    //adding shadows and other UI
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logoImageView.layer.cornerRadius = logoImageView.bounds.width / 2
        logoImageView.clipsToBounds = true
        logoImageView.contentMode = .scaleAspectFill

        logoImageContainer.layer.shadowColor = UIColor.black.cgColor
        logoImageContainer.layer.shadowOpacity = 0.25
        logoImageContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        logoImageContainer.layer.shadowRadius = 4
        logoImageContainer.layer.cornerRadius = logoImageContainer.bounds.width / 2
        logoImageContainer.layer.masksToBounds = false
    }
    //observing height of the table view
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            if let tbl = object as? UITableView, tbl == tableView, let newValue = change?[.newKey] as? CGSize {
                table_view_height.constant = newValue.height
                preferredContentSize = CGSize(width: view.frame.width, height: newValue.height)
            }
        }
    }
    //configuring the UI
    private func setupUI() {
        titleLabel.text = "My app helps users navigate, explore new locations, track their routes, and discover interesting places with interactive, real-time maps"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "side_menu_cell")
        tableView.isScrollEnabled = false
        tableView.reloadData()
    }
    //setting logo image
    func setLogo() {
        if let image = UIImage(named: "map") {
            logoImageView.image = image
        }
    }
}

//datasource and delegate of the table view
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
