## Background pushes

### Silent push

- Your server signals that new content is available; iOS can wake your app to refresh it.
- No alert, sound or badge. No alert permission needed.
- Requires Push Notifications capability, Remote notifications background mode, and APNs registration. Send the device token to your server; our demo lets you copy it for manual testing.
- Payload: `{"aps":{"content-available":1},"message":"Your takeaway is on its way"}`.
- APNs headers: `apns-push-type: background`, `apns-priority: 5`.
- Delivery isn't guaranteed. iOS can delay, throttle or coalesce pushes; use them to fetch current state, not as a reliable queue of events.
- Apple recommends no more than two or three per hour—not a fixed allowance.
- Once delivered, you have up to 30 seconds. Call the completion handler when finished.
- This example saves the message from the push to `Documents/message.txt`, returning `.newData` on success or `.failed` if the write fails.

In AppDelegate:

```swift
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    let message = userInfo["message"] as! String
    let file = URL.documentsDirectory.appending(path: "message.txt")
    do {
        try message.write(to: file, atomically: true, encoding: .utf8)
        completionHandler(.newData)
    } catch { completionHandler(.failed) }
}
```

[Apple: Pushing background updates to your app](https://developer.apple.com/documentation/usernotifications/pushing-background-updates-to-your-app)

### Notification service extension

- Runs in a separate extension before an alert notification appears—not in your main app.
- Useful for decrypting notification content or downloading attachments.
- Add a Notification Service Extension target, embedded in the app. The extension itself doesn't require the Remote notifications background mode.
- Send an alert payload with `"mutable-content": 1` inside `aps`. Silent notifications don't invoke it.
- This example changes the title so you can see that it ran.
- Call `contentHandler` with the resulting notification. You have up to 30 seconds.
- For asynchronous work, also implement `serviceExtensionTimeWillExpire()` to stop work and return fallback content.
- If the extension doesn't return content in time, iOS displays the original notification. For encrypted messages, use safe placeholder text in that original payload.
- A service extension processes notification content; a content extension customises its UI.

In the notification service extension target:

```swift
import UserNotifications
final class NotificationService: UNNotificationServiceExtension {
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        let content = request.content.mutableCopy() as! UNMutableNotificationContent
        content.title = "Edited by the service extension"
        contentHandler(content)
    }
}
```

[Apple: Notification service extensions](https://developer.apple.com/documentation/usernotifications/unnotificationserviceextension)

### Testing without a backend

- Easiest: use Apple's [Push Notifications Console](https://developer.apple.com/notifications/push-notifications-console/) with the device token copied from our app.
- Alternatively, send from your Mac using `curl`. This still sends a real remote notification through APNs—not a local notification.
- Replace `MY_DEVICE_TOKEN` and `MY_APNS_JWT`. The JWT is a provider authentication token signed using your APNs key, not the device token or the raw `.p8` key. Keep keys/tokens out of source control.
- These examples use the sandbox endpoint for a development-signed build. Production builds use `api.push.apple.com` and their production device token.
- The topic is the main app's bundle identifier, including when testing the extension.

Silent push:

```sh
curl --http2 "https://api.sandbox.push.apple.com/3/device/MY_DEVICE_TOKEN" \
  -H "authorization: bearer MY_APNS_JWT" \
  -H "apns-topic: com.jacob.BackgroundWork" \
  -H "apns-push-type: background" \
  -H "apns-priority: 5" \
  -d '{"aps":{"content-available":1},"message":"Your takeaway is on its way"}'
```

Service extension:

```sh
curl --http2 "https://api.sandbox.push.apple.com/3/device/MY_DEVICE_TOKEN" \
  -H "authorization: bearer MY_APNS_JWT" \
  -H "apns-topic: com.jacob.BackgroundWork" \
  -H "apns-push-type: alert" \
  -H "apns-priority: 10" \
  -d '{"aps":{"alert":{"title":"Original title","body":"Testing the extension"},"mutable-content":1}}'
```

- Run the app and register for pushes. For the extension demo, also enable notification alerts.
- Go Home without force-quitting, then send the push.
- Silent push: inspect `Documents/message.txt` in the app container; it should contain `Your takeaway is on its way`.
- Extension: look for the notification title `Edited by the service extension`.
- APNs accepting a request doesn't prove the app received it; check the callback or visible title.
- The silent-push snippet above is an illustrative update; the project still has the print-only callback. This updated snippet has not been build-tested. Real APNs delivery on the phone remains to be tested.

[Apple: Sending push notifications using command-line tools](https://developer.apple.com/documentation/usernotifications/sending-push-notifications-using-command-line-tools)
