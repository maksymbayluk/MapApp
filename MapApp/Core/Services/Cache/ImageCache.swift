//
//  ImageCache.swift
//  MapApp
//
//  Created by Максим Байлюк on 29.05.2025.
//
import Foundation
import UIKit


enum ImageCache {
    static let shared = NSCache<NSURL, UIImage>()
}
