import UIKit

@MainActor final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Capture ordinary print() calls for phone tests without a debugger.
        freopen(URL.documentsDirectory.appending(path: "events.txt").path, "a", stdout)
        setbuf(stdout, nil)
        print(Date(), "Launch:", UIDevice.current.systemVersion)
        RefreshService.shared.register()
        ProcessingService.shared.register()
        HealthResearchService.shared.register()
        ContinuedProcessingService.shared.register()
        _ = DownloadService.shared.session
        Task { try await GeofenceService.shared.start() }
        return true
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        DownloadService.shared.backgroundEventsFinished = completionHandler
        _ = DownloadService.shared.session
    }

func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    PushService.shared.token = deviceToken.map { String(format: "%02x", $0) }.joined()
}

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) { print(error) }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Background push received")
        completionHandler(.noData)
    }
}
