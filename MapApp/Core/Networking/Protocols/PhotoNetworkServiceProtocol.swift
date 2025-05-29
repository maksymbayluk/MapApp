//
//  PhotoNetworkServiceProtocol.swift
//  MapApp
//
//  Created by Максим Байлюк on 29.05.2025.
//
import Foundation

protocol PhotoNetworkServiceProtocol {
    func fetchPhotos(page: Int, limit: Int) async throws -> [Photo]
}
