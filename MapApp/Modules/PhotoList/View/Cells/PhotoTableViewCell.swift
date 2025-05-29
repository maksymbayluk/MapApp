//
//  PhotoTableViewCell.swift
//  MapApp
//
//  Created by Максим Байлюк on 29.05.2025.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var currentTask: Task<Void, Never>?

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        activityIndicator.stopAnimating()
        currentTask?.cancel()
        currentTask = nil
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .secondarySystemGroupedBackground
    }

    func configure(with viewModel: PhotoCellViewModel) {
        idLabel.text = viewModel.idText
        titleLabel.text = viewModel.title
        thumbnailImageView.image = nil
        activityIndicator.startAnimating()

        currentTask = Task {
            let image = await viewModel.loadImage()
            if !Task.isCancelled {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.thumbnailImageView.image = image
                }
            }
        }
    }
}
