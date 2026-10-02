import Foundation

// Delegate callbacks are on the main queue, matching this service's actor.
@MainActor final class DownloadService: NSObject, @preconcurrency URLSessionDownloadDelegate {
    static let shared = DownloadService()
    var backgroundEventsFinished: (() -> Void)?
    private var download: URLSessionDownloadTask?
    lazy var session = URLSession(configuration: .background(withIdentifier: "com.jacob.BackgroundWork.download"),
                                  delegate: self, delegateQueue: .main)

    func start() {
        download?.cancel()
        let video = URL(string: "https://devstreaming-cdn.apple.com/videos/wwdc/2025/227/4/b4d5d5a5-5c5a-4f37-a4ad-66fea0b6f25d/downloads/wwdc2025-227_hd.mp4")!
        download = session.downloadTask(with: video)
        download!.resume()
    }

    func stop() {
        download?.cancel()
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard (downloadTask.response as! HTTPURLResponse).statusCode == 200 else { return }
        let file = URL.documentsDirectory.appending(path: "wwdc-background-tasks.mp4")
        try? FileManager.default.removeItem(at: file)
        try! FileManager.default.moveItem(at: location, to: file)
        print(Date(), "Downloaded:", file.lastPathComponent)
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        backgroundEventsFinished?()
        backgroundEventsFinished = nil
    }
}
