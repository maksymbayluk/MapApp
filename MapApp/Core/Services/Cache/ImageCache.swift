//
//  ImageCache.swift
//  MapApp
//
//  Created by Максим Байлюк on 29.05.2025.
//
import Foundation
import UIKit

//enum that declares a shared singleton instance of NSCache that maps from NSURL keys to UIImage values
enum ImageCache {
    static let shared = NSCache<NSURL, UIImage>()
}
