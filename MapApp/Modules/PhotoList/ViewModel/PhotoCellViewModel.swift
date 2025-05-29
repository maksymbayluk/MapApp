//
//  PhotoCellViewModel.swift
//  MapApp
//
//  Created by Максим Байлюк on 29.05.2025.
//
import Foundation
import UIKit

struct PhotoCellViewModel {
    let idText: String
    let title: String
    let imageURL: URL?

    init(photo: Photo) {
        idText = "ID: \(photo.id)"
        title = photo.title
        imageURL = photo.thumbnailUrl
    }

    func loadImage() async -> UIImage? {
        let placeholder = UIImage(systemName: "photo")
        guard let url = imageURL else { return placeholder }

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
