import Observation
import UIKit
import UserNotifications

@MainActor @Observable final class PushService {
    static let shared = PushService()
    var token = ""

    func register() { UIApplication.shared.registerForRemoteNotifications() }

    func enableAlerts() async throws {
        _ = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
        register()
    }

}
