import UIKit

@MainActor final class BackgroundTimeService {
    static let shared = BackgroundTimeService()
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    func saveDraft() {
        backgroundTask = UIApplication.shared.beginBackgroundTask {
            UIApplication.shared.endBackgroundTask(self.backgroundTask)
        }
        let file = URL.documentsDirectory.appending(path: "draft.txt")
        let masterpiece = "It was the best of times, it was the blurst of times"
        try! masterpiece.write(to: file, atomically: true, encoding: .utf8)
        UIApplication.shared.endBackgroundTask(backgroundTask)
    }
}
