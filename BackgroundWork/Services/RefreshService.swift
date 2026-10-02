import BackgroundTasks

final class RefreshService {
    static let shared = RefreshService()

    func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.jacob.BackgroundWork.refresh", using: nil) { task in
            let url = URL(string: "https://developer.apple.com/news/rss/news.rss")!
            let fetch = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data, (response as? HTTPURLResponse)?.statusCode == 200, error == nil else {
                    task.setTaskCompleted(success: false)
                    return
                }
                try! data.write(to: URL.cachesDirectory.appending(path: "news.rss"))
                print("News refreshed")
                task.setTaskCompleted(success: true)
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
