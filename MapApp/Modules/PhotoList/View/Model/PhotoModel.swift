//
//  PhotoModel.swift
//  MapApp
//
//  Created by Максим Байлюк on 28.05.2025.
//
import Foundation

struct Photo: Decodable, Identifiable {
    let id: String
    let download_url: URL
    var thumbnailUrl: URL {
        URL(string: "https://picsum.photos/id/\(id)/150/150")!
    }

    var title: String {
        "Photo: \(id)"
    }
}

