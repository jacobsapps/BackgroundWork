import AVFAudio

@MainActor final class AudioService {
    static let shared = AudioService()
    var player: AVAudioPlayer?

    func play(_ file: URL = Bundle.main.url(forResource: "crawling-ragtime", withExtension: "mp3")!) throws {
        try AVAudioSession.sharedInstance().setCategory(.playback)
        try AVAudioSession.sharedInstance().setActive(true)
        player = try AVAudioPlayer(contentsOf: file)
        player!.play()
    }

    func stop() {
        player?.stop()
        player = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
