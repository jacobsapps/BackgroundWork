import AVFAudio

@MainActor final class RecordingService {
    static let shared = RecordingService()
    let file = URL.documentsDirectory.appending(path: "voice-memo.m4a")
    private var recorder: AVAudioRecorder?

    func start() async throws {
        guard await AVAudioApplication.requestRecordPermission() else { return }
        try AVAudioSession.sharedInstance().setCategory(.record)
        try AVAudioSession.sharedInstance().setActive(true)
        recorder = try AVAudioRecorder(url: file, settings: [AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44_100, AVNumberOfChannelsKey: 1])
        recorder!.record()
    }

    // Demo control; the article only needs the start/play example above.
    func stop() {
        recorder?.stop()
        recorder = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
