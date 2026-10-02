import ActivityKit

// This type must belong to both the app and Live Activity targets.
struct NearbyActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {}
}
