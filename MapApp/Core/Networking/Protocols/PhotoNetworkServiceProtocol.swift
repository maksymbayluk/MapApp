//
//  PhotoNetworkServiceProtocol.swift
//  MapApp
//
//  Created by Максим Байлюк on 29.05.2025.
//
import Foundation

//Protocol defining the interface of the service responsible for fetching photos
protocol PhotoNetworkServiceProtocol {
    func fetchPhotos(page: Int, limit: Int) async throws -> [Photo]
}
