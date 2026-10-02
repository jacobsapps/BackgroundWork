import SwiftUI

struct DemoListScreen: View {
    @State private var nearby = NearbyInteractionService.shared
    @State private var push = PushService.shared
    @State private var log = ""
    private let logFile = URL.documentsDirectory.appending(path: "events.txt")

    var body: some View {
        NavigationStack {
            List {
                Text("Run one demo at a time; stop before the next. Use Home or lock, not force-quit. Errors and results are in the log below.")
                    .font(.footnote)
                Section("1 · Buy a little time") {
                    Button("Save draft") { BackgroundTimeService.shared.saveDraft() }
                }
                Section("2 · Hand the transfer to iOS") {
                    Button("Download WWDC video · 99 MB") { DownloadService.shared.start() }
                    Button("Cancel download") { DownloadService.shared.stop() }
                    Text("Uses your current connection, including cellular.").font(.caption)
                }
                Section("3 · App refresh — later") {
                    Button("Schedule app refresh") { attempt { try RefreshService.shared.schedule() } }
                }
                Section("3 · File processing — later") {
                    Button("Schedule cached news cleanup") { attempt { try ProcessingService.shared.schedule() } }
                }
                Section("4 · Continued processing — now") {
                    Button("Compress a photo") { attempt { try ContinuedProcessingService.shared.start() } }
                    Text("Saves compressed-photo.jpg in Files. This small example may finish before you leave the app.").font(.caption)
                }
                Section("5 · Audio playback") {
                    Button("Play ragtime Crawling") {
                        RecordingService.shared.stop()
                        attempt { try AudioService.shared.play() }
                    }
                    Button("Stop playback") { AudioService.shared.stop() }
                }
                Section("5 · Microphone recording") {
                    Button("Record microphone") {
                        AudioService.shared.stop()
                        Task { do { try await RecordingService.shared.start() } catch { print(error) } }
                    }
                    Button("Stop recording") { RecordingService.shared.stop() }
                    Button("Play saved recording") {
                        RecordingService.shared.stop()
                        attempt { try AudioService.shared.play(RecordingService.shared.file) }
                    }
                }
                Section("5 · Geofence") {
                    Button("Monitor Apple Park · 200 m") { GeofenceService.shared.start() }
                    Button("Stop monitoring") { Task { await GeofenceService.shared.stop() } }
                    Text("Grant Always Location. Edit the hardcoded coordinate to test near you. Initial state is not an arrival.").font(.caption)
                }
                Section("5 · Nearby Interaction") {
                    Button("Prepare UWB session") { attempt { try nearby.prepare() } }
                    if !nearby.localToken.isEmpty {
                        ShareLink("Share this phone's token", item: nearby.localToken)
                        TextField("Paste the other phone's valid token", text: $nearby.peerToken)
                            .textInputAutocapitalization(.never).autocorrectionDisabled()
                        Button("Start ranging + Live Activity") { attempt { try nearby.start() } }
                    }
                    Button("Stop ranging") { Task { await nearby.stop() } }
                    Text("Two UWB-capable phones; exchange tokens in both directions.").font(.caption)
                }
                Section("5 · Silent push") {
                    Button("Register for background pushes") { push.register() }
                    if !push.token.isEmpty {
                        Button("Copy APNs device token") { UIPasteboard.general.string = push.token }
                    }
                    Text("Send content-available: 1 using Apple's Push Notifications Console.").font(.caption)
                }
                Section("Evidence") {
                    Button("Read log") { log = (try? String(contentsOf: logFile, encoding: .utf8)) ?? "" }
                    ShareLink("Export log", item: logFile)
                    Text(log.suffix(8_000)).font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
                }
            }
            .navigationTitle("Background Work")
        }
    }

    private func attempt(_ action: () throws -> Void) {
        do { try action() } catch { print(error) }
    }
}
