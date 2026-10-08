import SwiftUI
import NearbyInteraction

struct DemoListScreen: View {
    private let nearby = NearbyInteractionService.shared
    @State private var localToken = ""
    @State private var peerToken = ""
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
                    Text("App refresh is scheduled automatically when you leave the app. iOS decides when it runs.")
                }
                Section("3 · File processing — later") {
                    Text("Cache cleanup is scheduled automatically when you leave the app. iOS decides when it runs.")
                }
                Section("3 · Health research — later") {
                    Text("Requested when you leave the app. Requires Apple's health-research entitlement and study opt-in; this demo only prints the callback.")
                }
                Section("4 · Continued processing — now") {
                    Button("Prepare video with continued processing") { attempt { try ContinuedProcessingService.shared.start() } }
                    Text("Downloads 99 MB, creates a thumbnail, then saves both in Files. Progress counts finished steps, not bytes. Uses cellular if available.").font(.caption)
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
                Section("5 · Background location") {
                    Button("Print location updates") { LocationService.shared.start() }
                    Button("Stop location updates") { LocationService.shared.stop() }
                    Text("Grant location access, then leave the app. Coordinates print in the log. Stop after testing.").font(.caption)
                }
                Section("5 · Geofence") {
                    Text("Apple Park · 200 m — monitoring starts at app launch.")
                    Text("Grant Always Location. Edit Apple Park to somewhere near you, then cross into the circle. Logs when the region condition is satisfied. Disable location access in Settings to stop this demo.").font(.caption)
                }
                Section("5 · Nearby Interaction") {
                    Button("Prepare token to share") { attempt { try prepareToken() } }
                    if !localToken.isEmpty {
                        ShareLink("Share this phone's token", item: localToken)
                        TextField("Paste the other phone's valid token", text: $peerToken)
                            .textInputAutocapitalization(.never).autocorrectionDisabled()
                        Button("Start ranging + Live Activity") { attempt { try startRanging() } }
                    }
                    Button("Stop ranging") { Task { await nearby.stop() } }
                    Text("Two UWB-capable phones; exchange tokens in both directions. Tap Start once, then Stop before restarting.").font(.caption)
                }
                Section("5 · Silent push") {
                    Button("Register for background pushes") { push.register() }
                    if !push.token.isEmpty {
                        Button("Copy APNs device token") { UIPasteboard.general.string = push.token }
                    }
                    Button("Enable notification alerts") { Task { try await push.enableAlerts() } }
                    Text("Silent push: check the log. Mutable alert: background the app and look for ‘Edited by the service extension’. Payloads are in Examples/Push.").font(.caption)
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

    // Token transport belongs to the demo UI, not the Nearby Interaction snippet.
    private func prepareToken() throws {
        localToken = try NSKeyedArchiver.archivedData(withRootObject: nearby.session.discoveryToken!, requiringSecureCoding: true).base64EncodedString()
    }

    private func startRanging() throws {
        let data = Data(base64Encoded: peerToken.trimmingCharacters(in: .whitespacesAndNewlines))!
        let token = try NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data)!
        try nearby.start(with: token)
    }

    private func attempt(_ action: () throws -> Void) {
        do { try action() } catch { print(error) }
    }
}
