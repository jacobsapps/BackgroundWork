import ActivityKit
import NearbyInteraction

@MainActor final class NearbyInteractionService: NSObject, @preconcurrency NISessionDelegate {
    static let shared = NearbyInteractionService()
    lazy var session = NISession()
    private var activity: Activity<NearbyActivityAttributes>?

    func start(with peerToken: NIDiscoveryToken) throws {
        session.delegateQueue = .main
        session.delegate = self
        activity = try Activity.request(attributes: NearbyActivityAttributes(), content: ActivityContent(state: .init(), staleDate: nil))
        session.run(NINearbyPeerConfiguration(peerToken: peerToken))
    }

    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        if let distance = nearbyObjects.first?.distance { print("Distance:", distance, "m") }
    }

    // Demo control; pause preserves the discovery token so you can start again.
    func stop() async {
        session.pause()
        await activity?.end(nil, dismissalPolicy: .immediate)
        activity = nil
    }
}
