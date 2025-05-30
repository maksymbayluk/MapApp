//
//  ImageDownloadQueue.swift
//  MapApp
//
//  Created by Максим Байлюк on 29.05.2025.
//

import Foundation

//global constant
let imageDownloadQueue = ImageDownloadQueue()

//This is a queue to manage asynchronous image download tasks one at a time
actor ImageDownloadQueue {
    private var queue: [() async -> Void] = []
    private var isProcessing = false

    //adds a new async task to the queue and starts processing if not busy
    func add(_ task: @escaping () async -> Void) {
        queue.append(task)
        process()
    }
    
    //runs the next task in the queue, waits for it to finish, then continues with the next
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
