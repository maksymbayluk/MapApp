//
//  PhotoListViewModel.swift
//  MapApp
//
//  Created by Максим Байлюк on 29.05.2025.
//
import Foundation


// MARK: - AsyncMutex

actor AsyncMutex {
    func sync<T>(_ block: () throws -> T) rethrows -> T {
        return try block()
    }

    func syncAsync<T>(_ block: () async throws -> T) async rethrows -> T {
        return try await block()
    }
}


// MARK: - PhotoListViewModel

final class PhotoListViewModel: @unchecked Sendable {
    private let service: PhotoNetworkServiceProtocol

    private(set) var photos: [Photo] = []
    private var currentPage = 1
    private let limit = 20

    private var isLoading = false
    private var canLoadMore = true

    private let mutex = AsyncMutex()

    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    var onLoadingStatusChanged: ((Bool) -> Void)?

    init(service: PhotoNetworkServiceProtocol) {
        self.service = service
    }

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
