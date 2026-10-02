import CoreLocation

@MainActor final class GeofenceService {
    static let shared = GeofenceService()
    private var session: CLServiceSession?
    private var monitor: CLMonitor?
    private var monitoring: Task<Void, Error>?

    func start() {
        guard monitoring == nil else { return } // Only one instance of a named CLMonitor.
        UserDefaults.standard.set(true, forKey: "geofenceEnabled")
        session = CLServiceSession(authorization: .always)
        monitoring = Task {
            let monitor = await CLMonitor("BackgroundWorkFence")
            self.monitor = monitor
            if await monitor.identifiers.isEmpty {
                let center = CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090) // Apple Park; edit to test near you.
                await monitor.add(CLMonitor.CircularGeographicCondition(center: center, radius: 200), identifier: "here")
            }
            for try await event in await monitor.events {
                switch event.state {
                case .satisfied: print("Inside the geofence")
                case .unsatisfied: print("Outside the geofence")
                default: print("Geofence state unknown")
                }
            }
        }
    }

    func restore() {
        if UserDefaults.standard.bool(forKey: "geofenceEnabled") { start() }
    }

    func stop() async {
        UserDefaults.standard.set(false, forKey: "geofenceEnabled")
        monitoring?.cancel()
        _ = try? await monitoring?.value
        if let monitor { await monitor.remove("here") }
        monitoring = nil
        monitor = nil
        session?.invalidate()
        session = nil
        print("Geofence stopped")
    }
}
