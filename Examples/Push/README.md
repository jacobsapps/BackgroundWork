# Push demos

Use Apple's Push Notifications Console with the app's device token:
https://icloud.developer.apple.com/dashboard/notifications/

1. On a signed physical-device build, tap Register for remote notifications and copy the token.
2. For visible alerts, also tap Enable notification alerts and allow notifications.
3. Background the app using Home. Do not force-quit.
4. Send one of these payloads to the **app** topic `com.jacob.BackgroundWork`, not the extension bundle ID. Use the development/sandbox environment for the debug build.

| Payload | APNs headers | Evidence |
| --- | --- | --- |
| `silent.json` | `apns-push-type: background`, `apns-priority: 5` | Return to the app and tap Read log: `Background push received`. |
| `mutable-alert.json` | `apns-push-type: alert`, `apns-priority: 10` | Notification title becomes `Edited by the service extension`, not `Original title`. |

Silent pushes are discretionary, not immediate or guaranteed. The app callback has up to 30 seconds and must call its completion handler. This print-only demo returns `.noData` because it doesn't fetch anything. Silent pushes don't need alert permission; they do need APNs registration, the push entitlement and the remote-notification background mode.

The notification service extension runs separately from the app. It needs an alert payload with `mutable-content: 1`; silent pushes don't invoke it. It changes the title and immediately returns the content. No expiration override is needed for this synchronous demo; an asynchronous download/decryption example should also handle `serviceExtensionTimeWillExpire()` and return fallback content. This is not a notification content extension (custom notification UI), or the Nearby Live Activity widget.

Validation: build checked locally. Real APNs delivery and extension invocation on a physical device still need testing; a build or simulated payload alone does not prove APNs delivery.
