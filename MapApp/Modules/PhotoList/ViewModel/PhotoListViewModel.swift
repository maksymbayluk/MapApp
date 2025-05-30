//
//  PhotoListViewModel.swift
//  MapApp
//
//  Created by Максим Байлюк on 29.05.2025.
//
import Foundation

//utility that ensures that state changes like canLoadMore, canLoadMore, etc. are thread safe when accessed from Task
actor AsyncMutex {
    //sync block inside actor
    func sync<T>(_ block: () throws -> T) rethrows -> T {
        return try block()
    }
    //async block inside actor
    func syncAsync<T>(_ block: () async throws -> T) async rethrows -> T {
        return try await block()
    }
}


// MARK: - PhotoListViewModel

final class PhotoListViewModel: @unchecked Sendable {
    private let service: PhotoNetworkServiceProtocol
    //loaded photos list
    private(set) var photos: [Photo] = []
    //tracks pagination
    private var currentPage = 1
    //number of photos per page
    private let limit = 20
    //prevents overlapping fetches
    private var isLoading = false
    //disables fetching when no more data is expected
    private var canLoadMore = true
    //ensures safe access to shared state
    private let mutex = AsyncMutex()
    //closures
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    var onLoadingStatusChanged: ((Bool) -> Void)?

    init(service: PhotoNetworkServiceProtocol) {
        self.service = service
    }
    //trigger called during cell rendering to determine if the next page should be fetched
    func loadNextPageIfNeeded(currentIndex: Int) {
        Task { [weak self] in
            guard let strongSelf = self else { return }

            let shouldLoad = await strongSelf.mutex.sync {
                !strongSelf.isLoading && strongSelf.canLoadMore
            }

            if shouldLoad && currentIndex >= strongSelf.photos.count - 5 {
                await strongSelf.loadNextPage()
            }
        }
    }
    //Performs the actual photo loading with thread-safe access
    func loadNextPage() async {
        let alreadyLoading = await mutex.sync {
            if isLoading || !canLoadMore {
                return true
            } else {
                isLoading = true
                return false
            }
        }

        guard !alreadyLoading else { return }

        DispatchQueue.main.async { [weak self] in
            self?.onLoadingStatusChanged?(true)
        }

        do {
            let newPhotos = try await service.fetchPhotos(page: currentPage, limit: limit)

            await mutex.sync {
                if newPhotos.count < limit {
                    canLoadMore = false
                }
                photos.append(contentsOf: newPhotos)
                currentPage += 1
                isLoading = false
            }

            DispatchQueue.main.async { [weak self] in
                self?.onLoadingStatusChanged?(false)
                self?.onUpdate?()
            }

        } catch {
            await mutex.sync {
                isLoading = false
            }

            DispatchQueue.main.async { [weak self] in
                self?.onLoadingStatusChanged?(false)
                self?.onError?(error)
            }
        }
    }
}
