//
//  PhotoNetworkService.swift
//  MapApp
//
//  Created by Максим Байлюк on 29.05.2025.
//
import Foundation


class PhotoNetworkService: PhotoNetworkServiceProtocol {
    func fetchPhotos(page: Int, limit: Int) async throws -> [Photo] {
        let request = try PhotoEndpoint.photos(page: page, limit: limit).urlRequest()
        let (data, response) = try await URLSession.shared.data(for: request)

        guard
            let httpResponse = response as? HTTPURLResponse,
            200 ..< 300 ~= httpResponse.statusCode else
        {
            throw NetworkError.requestFailed
        }

        do {
            return try JSONDecoder().decode([Photo].self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}

