@preconcurrency import BackgroundTasks

final class ProcessingService {
    static let shared = ProcessingService()

    func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.jacob.BackgroundWork.processing", using: nil) { task in
            let cleanup = Task.detached {
                if !Task.isCancelled {
                    let file = URL.cachesDirectory.appending(path: "news.rss")
                    if FileManager.default.fileExists(atPath: file.path) {
                        try! FileManager.default.removeItem(at: file)
                    }
                    print("Cached news removed")
                }
                task.setTaskCompleted(success: !Task.isCancelled)
            }
            task.expirationHandler = { cleanup.cancel() }
        }
    }

    func schedule() throws {
        let request = BGProcessingTaskRequest(identifier: "com.jacob.BackgroundWork.processing")
        try BGTaskScheduler.shared.submit(request)
    }
}
