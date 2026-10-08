@preconcurrency import BackgroundTasks
import AVFoundation
import UIKit

final class ContinuedProcessingService {
    static let shared = ContinuedProcessingService()

    func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.jacob.BackgroundWork.continued", using: nil) { work in
            let operation = Task {
                do {
                    try await self.run(work as! BGContinuedProcessingTask)
                    work.setTaskCompleted(success: !Task.isCancelled)
                } catch {
                    work.setTaskCompleted(success: false)
                }
            }
            work.expirationHandler = { operation.cancel() }
        }
    }

    private func run(_ work: BGContinuedProcessingTask) async throws {
        work.progress.totalUnitCount = 3
        let video = try await downloadVideo()
        defer { try? FileManager.default.removeItem(at: video) }
        work.progress.completedUnitCount = 1

        try Task.checkCancellation()
        let thumbnail = try await makeThumbnail(for: video)
        work.progress.completedUnitCount = 2

        try Task.checkCancellation()
        try saveVideo(video, thumbnail: thumbnail)
        work.progress.completedUnitCount = 3
    }

    private func downloadVideo() async throws -> URL {
        let url = URL(string: "https://devstreaming-cdn.apple.com/videos/wwdc/2025/227/4/b4d5d5a5-5c5a-4f37-a4ad-66fea0b6f25d/downloads/wwdc2025-227_hd.mp4")!
        let (file, _) = try await URLSession.shared.download(from: url)
        return file
    }

    private func makeThumbnail(for video: URL) async throws -> Data {
        let generator = AVAssetImageGenerator(asset: AVURLAsset(url: video))
        generator.maximumSize = CGSize(width: 640, height: 360)
        let frame = try await generator.image(at: .zero)
        return UIImage(cgImage: frame.image).jpegData(compressionQuality: 0.8)!
    }

    private func saveVideo(_ video: URL, thumbnail: Data) throws {
        let file = URL.documentsDirectory.appending(path: "continued-download.mp4")
        try? FileManager.default.removeItem(at: file)
        try FileManager.default.moveItem(at: video, to: file)
        try thumbnail.write(to: URL.documentsDirectory.appending(path: "continued-thumbnail.jpg"))
    }

    func start() throws {
        let request = BGContinuedProcessingTaskRequest(identifier: "com.jacob.BackgroundWork.continued",
            title: "Preparing a WWDC video", subtitle: "Downloading, creating thumbnail, then saving")
        request.strategy = .fail
        try BGTaskScheduler.shared.submit(request)
    }
}
