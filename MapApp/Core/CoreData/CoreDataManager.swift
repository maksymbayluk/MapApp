//
//  CoreDataManager.swift
//  MapApp
//
//  Created by Максим Байлюк on 30.05.2025.
//

import CoreData
import CoreLocation
import MapKit

// MARK: - CoreDataManager

final class CoreDataManager {
    static let shared = CoreDataManager()

    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MapApp")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData error: \(error)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    //Fetching all core data RoutePoint values
    func fetchAllPoints() -> [RoutePoint] {
        let request: NSFetchRequest<RoutePoint> = RoutePoint.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }
    //Fetches route points (locations) from Core Data and returns the coordinates of the most recent points covering up to a specified total distance, by default 1000 meters
    func fetchRoutePointsForLast(distance maxDistance: CLLocationDistance = 1000) -> [CLLocationCoordinate2D] {
        let request: NSFetchRequest<RoutePoint> = RoutePoint.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]

        do {
            let points = try context.fetch(request)
            var recentPoints: [CLLocationCoordinate2D] = []
            var totalDistance: CLLocationDistance = 0

            for i in stride(from: points.count - 1, through: 1, by: -1) {
                let current = points[i]
                let previous = points[i - 1]

                let currentLoc = CLLocation(latitude: current.latitude, longitude: current.longitude)
                let previousLoc = CLLocation(latitude: previous.latitude, longitude: previous.longitude)

                let segmentDistance = currentLoc.distance(from: previousLoc)
                totalDistance += segmentDistance

                if recentPoints.isEmpty {
                    recentPoints.append(currentLoc.coordinate)
                }

                recentPoints.append(previousLoc.coordinate)

                if totalDistance >= maxDistance {
                    break
                }
            }
            return recentPoints.reversed()
        } catch {
            print("Failed to fetch points: \(error)")
            return []
        }
    }
    //Calculates the total distance of the entire route using all stored points
    func calculateTotalDistance() -> CLLocationDistance {
        let points = fetchAllPoints()
        guard points.count >= 2 else { return 0 }

        var total: CLLocationDistance = 0
        for i in 1 ..< points.count {
            let loc1 = CLLocation(latitude: points[i - 1].latitude, longitude: points[i - 1].longitude)
            let loc2 = CLLocation(latitude: points[i].latitude, longitude: points[i].longitude)
            total += loc1.distance(from: loc2)
        }
        return total
    }
    //Saves any changes made in the Core Data context
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            try? context.save()
        }
    }
    //Deletes old route points to prevent the database from growing
    func clearOldPoints() {
        let request: NSFetchRequest<RoutePoint> = RoutePoint.fetchRequest()
        let sort = NSSortDescriptor(key: "timestamp", ascending: false)
        request.sortDescriptors = [sort]
        request.fetchOffset = 100
        request.fetchLimit = 10000

        if let oldPoints = try? context.fetch(request) {
            oldPoints.forEach { context.delete($0) }
            saveContext()
        }
    }
    //Saving point to Core Data
    func saveRoutePoint(from location: CLLocation) {
        let point = RoutePoint(context: context)
        point.latitude = location.coordinate.latitude
        point.longitude = location.coordinate.longitude
        point.timestamp = Date()
        saveContext()
        clearOldPoints()
    }
}

extension CoreDataManager {
    //Returns a polyline representing the route for the last 1 km
    func fetchRoutePolylineForLast(distance maxDistance: CLLocationDistance = 1000) -> MKPolyline? {
        let coords = fetchRoutePointsForLast(distance: maxDistance)
        guard coords.count > 1 else { return nil }
        return MKPolyline(coordinates: coords, count: coords.count)
    }
}
