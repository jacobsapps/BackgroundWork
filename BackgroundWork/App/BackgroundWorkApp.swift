import SwiftUI

@main struct BackgroundWorkApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup { DemoListScreen() }
            .onChange(of: scenePhase) { _, phase in
                if phase == .background {
                    try? RefreshService.shared.schedule()
                    try? ProcessingService.shared.schedule()
                    try? HealthResearchService.shared.schedule()
                }
            }
    }
}
