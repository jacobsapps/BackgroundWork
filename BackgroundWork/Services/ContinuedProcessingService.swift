@preconcurrency import BackgroundTasks
import UIKit

final class ContinuedProcessingService {
    static let shared = ContinuedProcessingService()

    func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.jacob.BackgroundWork.continued", using: nil) { task in
            let task = task as! BGContinuedProcessingTask
            task.progress.totalUnitCount = 1
            let export = Task.detached {
                if !Task.isCancelled {
                    let photo = UIImage(contentsOfFile: Bundle.main.path(forResource: "mountain", ofType: "jpg")!)!
                    let file = URL.documentsDirectory.appending(path: "compressed-photo.jpg")
                    try! photo.jpegData(compressionQuality: 0.5)!.write(to: file)
                    task.progress.completedUnitCount = 1
                }
                task.setTaskCompleted(success: !Task.isCancelled)
            }
            task.expirationHandler = { export.cancel() }
        }
    }

    func start() throws {
        let request = BGContinuedProcessingTaskRequest(identifier: "com.jacob.BackgroundWork.continued",
            title: "Compressing a photo", subtitle: "Saving a smaller JPEG")
        request.strategy = .fail
        try BGTaskScheduler.shared.submit(request)
    }
}
