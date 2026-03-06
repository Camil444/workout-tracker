import Foundation
import SwiftData
import CoreLocation

@Model
final class GymLocation {
    var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var radiusMeters: Double
    var isPrimary: Bool
    var activityType: String // "musculation", "running", "sport"

    init(
        name: String,
        latitude: Double,
        longitude: Double,
        radiusMeters: Double = 100,
        isPrimary: Bool = false,
        activityType: String = "musculation"
    ) {
        self.id = UUID()
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.radiusMeters = radiusMeters
        self.isPrimary = isPrimary
        self.activityType = activityType
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
