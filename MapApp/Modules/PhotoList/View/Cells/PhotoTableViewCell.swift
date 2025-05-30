//
//  PhotoTableViewCell.swift
//  MapApp
//
//  Created by Максим Байлюк on 29.05.2025.
//

import UIKit

//table view cell for image view(and loading indicator), id, and title
class PhotoTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    //A reference to the asynchronous image loading task so it can be cancelled when the cell is reused
    private var currentTask: Task<Void, Never>?
    
    //Called before the cell is reused in the table view
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
    //Configures the cell using a ViewModel
    func configure(with viewModel: PhotoCellViewModel) {
        idLabel.text = viewModel.idText
        titleLabel.text = viewModel.title
        thumbnailImageView.image = nil
        activityIndicator.startAnimating()
        //Launches an asynchronous image load
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
