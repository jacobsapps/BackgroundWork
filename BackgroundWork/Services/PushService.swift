import Observation
import UIKit

@MainActor @Observable final class PushService {
    static let shared = PushService()
    var token = ""

    func register() { UIApplication.shared.registerForRemoteNotifications() }

    func receive() -> UIBackgroundFetchResult {
        print("Background push received")
        return .noData
    }
}
