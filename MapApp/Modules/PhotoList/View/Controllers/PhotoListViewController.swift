//
//  ListViewController.swift
//  MapApp
//
//  Created by Максим Байлюк on 27.05.2025.
//
import UIKit

class PhotoListViewController: UITableViewController {

    var viewModel: PhotoListViewModel?
    private var photoViewModels: [PhotoCellViewModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "List"
        configureTableView()
        bindViewModel()
        Task {
            await viewModel?.loadNextPage()
        }
    }

    func configureTableView() {
        let nib = UINib(nibName: "PhotoTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "PhotoCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0
        tableView.estimatedRowHeight = 80
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LoadingCell")
    }

    private func bindViewModel() {
        viewModel?.onUpdate = { [weak self] in
            self?.photoViewModels = self?.viewModel?.photos.map { PhotoCellViewModel(photo: $0) } ?? []
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }

        viewModel?.onError = { error in
            print("Error: \(error)")
        }

        viewModel?.onLoadingStatusChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.tableView.tableFooterView = self?.createSpinnerFooter()
                } else {
                    self?.tableView.tableFooterView = nil
                }
            }
        }
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return photoViewModels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        viewModel?.loadNextPageIfNeeded(currentIndex: indexPath.row)

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as? PhotoTableViewCell else {
            return UITableViewCell()
        }

        let vm = photoViewModels[indexPath.row]
        cell.configure(with: vm)
        return cell
    }

    private func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.center = footerView.center
        spinner.startAnimating()
        footerView.addSubview(spinner)
        return footerView
    }
}


