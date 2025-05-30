//
//  PhotoCellViewModel.swift
//  MapApp
//
//  Created by Максим Байлюк on 29.05.2025.
//
import Foundation
import UIKit

//view model for use in table view cell
struct PhotoCellViewModel {
    let idText: String
    let title: String
    let imageURL: URL?

    init(photo: Photo) {
        idText = "ID: \(photo.id)"
        title = photo.title
        imageURL = photo.thumbnailUrl
    }
    //Asynchronously loads and caches a thumbnail image
    func loadImage() async -> UIImage? {
        //returns a placeholder system image if image url is nil
        let placeholder = UIImage(systemName: "photo")
        guard let url = imageURL else { return placeholder }
        //If not cached, downloads the image with URLSession
        if let cachedImage = ImageCache.shared.object(forKey: url as NSURL) {
            return cachedImage
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return placeholder }
            ImageCache.shared.setObject(image, forKey: url as NSURL)
            return image
        } catch {
            return placeholder
        }
    }
}
