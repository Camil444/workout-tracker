import Foundation
import CoreLocation
import SwiftData
import UserNotifications

@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var currentLocation: CLLocation?
    var isMonitoring = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.allowsBackgroundLocationUpdates = false
        authorizationStatus = manager.authorizationStatus
    }

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func requestAlwaysAuthorization() {
        manager.requestAlwaysAuthorization()
    }

    func requestCurrentLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return
        }
        manager.requestLocation()
    }

    // MARK: - Geofencing

    func startMonitoring(locations: [GymLocation]) {
        guard authorizationStatus == .authorizedAlways else { return }

        // Clear old regions
        for region in manager.monitoredRegions {
            manager.stopMonitoring(for: region)
        }

        // Monitor new ones (max 20 regions per app)
        for location in locations.prefix(20) {
            let region = CLCircularRegion(
                center: location.coordinate,
                radius: location.radiusMeters,
                identifier: location.id.uuidString
            )
            region.notifyOnEntry = true
            region.notifyOnExit = false
            manager.startMonitoring(for: region)
        }
        isMonitoring = true
    }

    func stopMonitoring() {
        for region in manager.monitoredRegions {
            manager.stopMonitoring(for: region)
        }
        isMonitoring = false
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            self.currentLocation = locations.last
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[LocationManager] Error: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        sendWorkoutNotification(regionID: region.identifier)
    }

    // MARK: - Notifications

    static func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    private func sendWorkoutNotification(regionID: String) {
        let content = UNMutableNotificationContent()
        content.title = "C'est l'heure ! 💪"
        content.body = "Tu es arrivé à ta salle. Prêt pour une séance ?"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "gym-arrival-\(regionID)",
            content: content,
            trigger: nil // Immediate
        )
        UNUserNotificationCenter.current().add(request)
    }
}
