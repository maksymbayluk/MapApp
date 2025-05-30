//
//  PhotoNetworkService.swift
//  MapApp
//
//  Created by Максим Байлюк on 29.05.2025.
//
import Foundation

//Class that conforms to PhotoNetworkServiceProtocol to fetch photos from a network
class PhotoNetworkService: PhotoNetworkServiceProtocol {
    //Fetches photos, checks for errors and decodes the received json data into an array of objects
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

