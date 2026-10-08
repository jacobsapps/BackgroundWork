import BackgroundTasks

final class RefreshService {
    static let shared = RefreshService()

    func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.jacob.BackgroundWork.refresh", using: nil) { task in
            let url = URL(string: "https://developer.apple.com/news/rss/news.rss")!
            let fetch = URLSession.shared.dataTask(with: url) { data, _, error in
                try? data?.write(to: URL.cachesDirectory.appending(path: "news.rss"))
                task.setTaskCompleted(success: error == nil)
            }
            task.expirationHandler = { fetch.cancel() }
            fetch.resume()
        }
    }

    func schedule() throws {
        let request = BGAppRefreshTaskRequest(identifier: "com.jacob.BackgroundWork.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60)
        try BGTaskScheduler.shared.submit(request)
    }
}
