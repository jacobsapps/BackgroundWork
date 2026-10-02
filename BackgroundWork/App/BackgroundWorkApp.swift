import SwiftUI

@main struct BackgroundWorkApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    var body: some Scene {
        WindowGroup { DemoListScreen() }
    }
}
