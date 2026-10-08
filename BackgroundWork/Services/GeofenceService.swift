import CoreLocation

@MainActor final class GeofenceService {
    static let shared = GeofenceService()
    private var authorization: CLServiceSession?

    func start() async throws {
        authorization = CLServiceSession(authorization: .always)
        let monitor = await CLMonitor("AppleGeofence")
        let center = CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090)
        await monitor.add(CLMonitor.CircularGeographicCondition(center: center, radius: 200), identifier: "ApplePark")
        for try await event in await monitor.events {
            if event.state == .satisfied { print("Inside Apple Park") }
        }
    }
}
