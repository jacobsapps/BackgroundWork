import SwiftUI

@main struct RuntimeProbeApp: App {
    @Environment(\.scenePhase) private var phase
    @State private var started = false

    init() { Probe.shared.register() }

    var body: some Scene {
        WindowGroup {
            VStack(spacing: 20) {
                Text("Background Runtime Probe").font(.title)
                Text("Finite JPEG-encoding benchmark. Stop after 2 hours.\nLeave this app after starting; don't force-quit.")
                Button("Run UIKit baseline") { Probe.shared.start("uikit") }
                Button("Run continued processing") { Probe.shared.start("continued") }
                Button("Stop experiment") { Probe.shared.stop() }
                Text("Results: Files → Runtime Probe.\nNo debugger. No audio, location, or networking.").font(.caption)
            }
            .padding()
            .onAppear {
                guard !started else { return }
                started = true
                if CommandLine.arguments.contains("uikit") { Probe.shared.start("uikit") }
                if CommandLine.arguments.contains("continued") { Probe.shared.start("continued") }
            }
        }
        .onChange(of: phase) { _, phase in
            RunLog.shared.phase(String(describing: phase))
        }
    }
}
