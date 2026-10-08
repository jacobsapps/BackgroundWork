import BackgroundTasks

// Requires com.apple.developer.backgroundtasks.healthresearch and study opt-in.
final class HealthResearchService {
    static let shared = HealthResearchService()

    func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.jacob.BackgroundWork.healthResearch", using: nil) { task in
            print("Health research task received — demo only, no health data")
            task.setTaskCompleted(success: true)
        }
    }

    func schedule() throws {
        let request = BGHealthResearchTaskRequest(identifier: "com.jacob.BackgroundWork.healthResearch")
        request.protectionTypeOfRequiredData = FileProtectionType.completeUntilFirstUserAuthentication.rawValue as NSString
        try BGTaskScheduler.shared.submit(request)
    }
}
