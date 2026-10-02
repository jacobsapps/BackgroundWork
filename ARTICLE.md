**“I start some work, then leave the app. What happens next?”**

Start with the baseline: iOS suspends your process. Moving work off the main thread doesn’t change that.

### 1. Buy a little time
**`UIApplication.beginBackgroundTask`**
- Finish something already underway.
- Limited runway; expiration, cancellation and cleanup.
- Your watchdog-termination experience belongs here.

### 2. Hand the transfer to iOS
**Background `URLSession`**
- Instead of keeping your app alive, let the system transfer the file.
- Your process can suspend; delegate callbacks deliver the result.
- Briefly cross-reference your uploading article.

### 3. Ask iOS to run your code later
Two separate API entries:
- **`BGAppRefreshTask`** — small content updates.
- **`BGProcessingTask`** — heavier maintenance.

Both existed before iOS 26. The limitation: **iOS chooses when**, not you.

### 4. Finish work the user starts now
**`BGContinuedProcessingTask`**
- The iOS 26 payoff: start a substantial operation and leave the app without abandoning it.
- System progress/cancellation UI; still subject to expiration.
- Optional small comparison with the UIKit example—not a sprawling benchmark.

### 5. Feature-specific exceptions
Keep these separate from general-purpose execution, with individual entries:
- Audio playback.
- Microphone recording.
- Location/geofencing.
- Nearby Interaction/UWB.
- Silent pushes and notification service extensions—briefly.
- Remaining background modes: reference list.
