//
//  ListViewController.swift
//  MapApp
//
//  Created by Максим Байлюк on 27.05.2025.
//
import UIKit

// MARK: - PhotoListViewController
//class that displays a list of photos using view models, supports pagination, and handles loading states and errors (like no internet)
class PhotoListViewController: UITableViewController {
    //The main view model responsible for providing data and triggering UI updates
    var viewModel: PhotoListViewModel?
    //Internal cache of photo cell view models used to configure cells
    private var photoViewModels: [PhotoCellViewModel] = []
    //lifecycle
    init() {
        super.init(style: .insetGrouped)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "List"
        configureTableView()
        bindViewModel()
        //Triggers initial data load via viewModel.loadNextPage()
        Task {
            await self.viewModel?.loadNextPage()
        }
    }
    //config of table view
    func configureTableView() {
        let nib = UINib(nibName: "PhotoTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "PhotoCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0
        tableView.estimatedRowHeight = 80
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LoadingCell")
    }
    //Attaches three closures
    private func bindViewModel() {
        viewModel?.onUpdate = { [weak self] in
            self?.photoViewModels = self?.viewModel?.photos.map { PhotoCellViewModel(photo: $0) } ?? []
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }

        viewModel?.onError = { [weak self] error in
            DispatchQueue.main.async {
                if self?.isInternetError(error) == true {
                    self?.NoInternetMessage(shown: true)
                } else {
                    self?.NoInternetMessage(shown: false)
                }
            }
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
    //table view delegate and data source
    override func numberOfSections(in _: UITableView) -> Int {
        return photoViewModels.count
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        viewModel?.loadNextPageIfNeeded(currentIndex: indexPath.section)

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as? PhotoTableViewCell else {
            return UITableViewCell()
        }

        let vm = photoViewModels[indexPath.section]
        cell.configure(with: vm)
        return cell
    }

    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 10
    }

    override func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    //Returns a loading spinner view to be used as tableFooterView during pagination loading
    private func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.center = footerView.center
        spinner.startAnimating()
        footerView.addSubview(spinner)
        return footerView
    }
    //Shows or hides a red label at the top of the table for connectivity issues
    private func NoInternetMessage(shown: Bool) {
        let label = UILabel()
        label.text = "No Internet Connection"
        label.textColor = .systemRed
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 16)
        label.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 50)
        tableView.tableHeaderView = label
        label.isHidden = !shown
    }
}

extension PhotoListViewController {
    //Detects if an error is a known network-related error
    private func isInternetError(_ error: Error) -> Bool {
        let nsError = error as NSError
        let networkErrorCodes: [Int] = [
            NSURLErrorNotConnectedToInternet,
            NSURLErrorTimedOut,
            NSURLErrorNetworkConnectionLost,
        ]
        return networkErrorCodes.contains(nsError.code)
    }
}


