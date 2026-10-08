@preconcurrency import BackgroundTasks
import UIKit

// Instrumentation belongs here, not in the article's services.
final class RunLog: @unchecked Sendable {
    static let shared = RunLog()
    private let lock = NSLock()
    private var file: FileHandle?
    private var start = ProcessInfo.processInfo.systemUptime
    private var background: Double?

    func begin(_ mode: String) {
        lock.lock()
        defer { lock.unlock() }
        try? file?.close()
        start = ProcessInfo.processInfo.systemUptime
        background = nil
        let name = "\(Int(Date().timeIntervalSince1970))-\(mode)-\(UUID().uuidString.prefix(6)).jsonl"
        let url = URL.documentsDirectory.appending(path: name)
        FileManager.default.createFile(atPath: url.path, contents: nil)
        file = try! FileHandle(forWritingTo: url)
    }

    func phase(_ value: String) {
        lock.lock()
        if value == "background", background == nil { background = ProcessInfo.processInfo.systemUptime }
        lock.unlock()
        event("phase", ["phase": value])
    }

    func event(_ name: String, _ values: [String: Any] = [:]) {
        lock.lock()
        defer { lock.unlock() }
        let now = ProcessInfo.processInfo.systemUptime
        var record = values
        record["event"] = name
        record["utc"] = ISO8601DateFormatter().string(from: Date())
        record["elapsedSeconds"] = now - start
        record["backgroundSeconds"] = background.map { now - $0 }
        record["thermalState"] = ProcessInfo.processInfo.thermalState.rawValue
        record["lowPowerMode"] = ProcessInfo.processInfo.isLowPowerModeEnabled
        let line = try! JSONSerialization.data(withJSONObject: record, options: [.sortedKeys]) + Data([10])
        try? file?.write(contentsOf: line)
        try? file?.synchronize()
    }
}

@MainActor final class Probe {
    static let shared = Probe()
    private var progress: Progress?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var active = false

    func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.jacob.BackgroundWork.RuntimeProbe.continued", using: .main) { task in
            MainActor.assumeIsolated {
                self.runContinued(task as! BGContinuedProcessingTask)
            }
        }
    }

    func start(_ mode: String) {
        guard !active else { return }
        active = true
        UIDevice.current.isBatteryMonitoringEnabled = true
        RunLog.shared.begin(mode)
        RunLog.shared.event("requested", ["mode": mode, "os": UIDevice.current.systemVersion,
            "device": UIDevice.current.model, "batteryLevel": UIDevice.current.batteryLevel,
            "batteryState": UIDevice.current.batteryState.rawValue, "workload": "100000 JPEG encodes of bundled 10109x4542 image at quality 0.5", "cutoffSeconds": 7200])
        if mode == "continued" {
            let request = BGContinuedProcessingTaskRequest(identifier: "com.jacob.BackgroundWork.RuntimeProbe.continued", title: "Runtime experiment", subtitle: "JPEG encoding · 2 hour cap")
            request.strategy = .fail
            do { try BGTaskScheduler.shared.submit(request) }
            catch {
                RunLog.shared.event("submission_failed", ["error": String(describing: error)])
                active = false
            }
        } else {
            let progress = Progress(totalUnitCount: 100_000)
            self.progress = progress
            backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "Runtime experiment") {
                RunLog.shared.event("expiration")
                progress.cancel()
                self.endUIKit()
            }
            guard backgroundTask != .invalid else {
                RunLog.shared.event("assertion_unavailable")
                active = false
                return
            }
            run(progress) { self.endUIKit() }
        }
    }

    private func runContinued(_ work: BGContinuedProcessingTask) {
        work.progress.totalUnitCount = 100_000
        progress = work.progress
        work.expirationHandler = {
            RunLog.shared.event("expiration")
            work.progress.cancel()
        }
        run(work.progress) {
            work.setTaskCompleted(success: work.progress.isFinished && !work.progress.isCancelled)
        }
    }

    private func run(_ progress: Progress, finish: @escaping @MainActor () -> Void) {
        DispatchQueue.global(qos: .utility).async {
            RunLog.shared.event("work_started")
            let start = ProcessInfo.processInfo.systemUptime
            var lastLog = start
            var bytes = 0
            let photo = UIImage(contentsOfFile: Bundle.main.path(forResource: "mountain", ofType: "jpg")!)!
            while progress.completedUnitCount < progress.totalUnitCount && !progress.isCancelled {
                if ProcessInfo.processInfo.systemUptime - start >= 7200 {
                    RunLog.shared.event("observation_cutoff")
                    break
                }
                autoreleasepool {
                    bytes += photo.jpegData(compressionQuality: 0.5)!.count
                }
                progress.completedUnitCount += 1
                let now = ProcessInfo.processInfo.systemUptime
                if now - lastLog >= 5 {
                    RunLog.shared.event("checkpoint", ["images": progress.completedUnitCount, "encodedBytes": bytes])
                    lastLog = now
                }
            }
            RunLog.shared.event("work_stopped", ["images": progress.completedUnitCount, "cancelled": progress.isCancelled, "batchCompleted": progress.isFinished])
            DispatchQueue.main.async {
                finish()
                self.active = false
                self.progress = nil
                RunLog.shared.event("execution_released")
            }
        }
    }

    func stop() {
        RunLog.shared.event("user_stop")
        progress?.cancel()
    }

    private func endUIKit() {
        guard backgroundTask != .invalid else { return }
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
}
