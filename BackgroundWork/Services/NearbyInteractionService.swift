import ActivityKit
import NearbyInteraction
import Observation

// The attributes type is also compiled into the Live Activity extension.
@MainActor @Observable final class NearbyInteractionService: NSObject, @preconcurrency NISessionDelegate {
    static let shared = NearbyInteractionService()
    var localToken = ""
    var peerToken = ""
    private var session: NISession?

    func prepare() throws {
        guard NISession.deviceCapabilities.supportsPreciseDistanceMeasurement else { throw CocoaError(.featureUnsupported) }
        session?.invalidate()
        session = NISession()
        session!.delegateQueue = .main
        session!.delegate = self
        localToken = try NSKeyedArchiver.archivedData(withRootObject: session!.discoveryToken!, requiringSecureCoding: true).base64EncodedString()
    }

    func start() throws {
        let data = Data(base64Encoded: peerToken.trimmingCharacters(in: .whitespacesAndNewlines))!
        let token = try NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data)!
        if Activity<NearbyActivityAttributes>.activities.isEmpty {
            _ = try Activity.request(attributes: NearbyActivityAttributes(), content: ActivityContent(state: .init(), staleDate: nil))
        }
        session!.run(NINearbyPeerConfiguration(peerToken: token))
    }

    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        if let distance = nearbyObjects.first?.distance { print("UWB distance:", distance, "m") }
    }

    func stop() async {
        session?.invalidate()
        session = nil
        localToken = ""
        peerToken = ""
        for activity in Activity<NearbyActivityAttributes>.activities { await activity.end(nil, dismissalPolicy: .immediate) }
    }
}
