//
//  NetworkError.swift
//  MapApp
//
//  Created by Максим Байлюк on 29.05.2025.
//
import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
}
