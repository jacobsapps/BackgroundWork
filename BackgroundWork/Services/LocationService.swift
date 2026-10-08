import CoreLocation

@MainActor final class LocationService: NSObject, @preconcurrency CLLocationManagerDelegate {
    static let shared = LocationService()
    private let manager = CLLocationManager()

    func start() {
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location:", locations.last!.coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

    // Demo control; don't leave location tracking running after testing.
    func stop() { manager.stopUpdatingLocation() }
}
