@preconcurrency import BackgroundTasks

final class ProcessingService {
    static let shared = ProcessingService()

    func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.jacob.BackgroundWork.processing", using: nil) { task in
            let file = URL.cachesDirectory.appending(path: "news.rss")
            try? FileManager.default.removeItem(at: file)
            task.setTaskCompleted(success: true)
        }
    }

    func schedule() throws {
        let request = BGProcessingTaskRequest(identifier: "com.jacob.BackgroundWork.processing")
        try BGTaskScheduler.shared.submit(request)
    }
}
