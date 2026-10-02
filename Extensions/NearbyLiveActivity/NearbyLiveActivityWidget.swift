import ActivityKit
import SwiftUI
import WidgetKit

/// Lock Screen / Dynamic Island UI for the UWB example, not a Home Screen widget.
@main struct NearbyLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NearbyActivityAttributes.self) { _ in
            Label("Background UWB ranging", systemImage: "dot.radiowaves.left.and.right").padding()
        } dynamicIsland: { _ in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) { Text("Background UWB ranging") }
            } compactLeading: {
                Image(systemName: "dot.radiowaves.left.and.right")
            } compactTrailing: {
                Text("UWB")
            } minimal: {
                Image(systemName: "dot.radiowaves.left.and.right")
            }
        }
    }
}
