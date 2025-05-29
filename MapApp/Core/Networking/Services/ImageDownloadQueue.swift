//
//  ImageDownloadQueue.swift
//  MapApp
//
//  Created by Максим Байлюк on 29.05.2025.
//

import Foundation


let imageDownloadQueue = ImageDownloadQueue()

// MARK: - ImageDownloadQueue

actor ImageDownloadQueue {
    private var queue: [() async -> Void] = []
    private var isProcessing = false

    func add(_ task: @escaping () async -> Void) {
        queue.append(task)
        process()
    }

    private func process() {
        guard !isProcessing, !queue.isEmpty else { return }
        isProcessing = true
        Task {
            let task = queue.removeFirst()
            await task()
            isProcessing = false
            process()
        }
    }
}
