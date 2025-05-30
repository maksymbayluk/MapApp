//
//  PhotoEndpoint.swift
//  MapApp
//
//  Created by Максим Байлюк on 29.05.2025.
//
import Foundation

//Represents an endpoint to fetch a list of photos(items on list vc)
enum PhotoEndpoint {
    
    case photos(page: Int, limit: Int)

    private static let baseURL = URL(string: "https://picsum.photos")!
    
    //Making url - computed property
    var url: URL? {
        switch self {
        case let .photos(page, limit):
            var components = URLComponents(url: Self.baseURL.appendingPathComponent("/v2/list"), resolvingAgainstBaseURL: false)
            components?.queryItems = [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "limit", value: "\(limit)"),
            ]
            return components?.url
        }
    }
    
    //Returning url request
    func urlRequest() throws -> URLRequest {
        guard let url = url else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
}



