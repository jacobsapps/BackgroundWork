# Background Work

One small service per API. Open `BackgroundWork.xcodeproj`.
These are deliberately happy-path article demos: hardcoded inputs, force-unwrapped
bundled assets, no retry framework, no shared network helper. Necessary cancellation,
completion callbacks and retained objects are kept.

## Where to read

- `BackgroundWork/Services/`: the API examples. Each file declares its own values
  and uses only Apple frameworks; UWB also needs the shared ActivityKit attributes.
- `BackgroundWork/App/`: launch registration and the required app-delegate callbacks.
- `BackgroundWork/Screens/`: buttons only, in the article's order.
- `BackgroundWork/Resources/`: the ragtime MP3 and sample photo.
- `BackgroundWork/Configuration/`: permissions, background modes, BGTask identifiers.
- `Extensions/NearbyLiveActivity/`: the UWB Live Activity and its shared attributes.
  **BGContinuedProcessingTask does not use this extension.**

## The examples

| Service | All it does |
| --- | --- |
| BackgroundTimeService | Save a draft to Documents/draft.txt. |
| DownloadService | Download the 99 MB WWDC video to Documents. |
| RefreshService | Fetch Apple's developer news RSS into Caches/news.rss. |
| ProcessingService | Delete that cached news file if it exists. |
| HealthResearchService | Print the health-research task callback; no health data is accessed. |
| ContinuedProcessingService | Download video, generate a thumbnail, then save both in Documents. |
| AudioService | Play the bundled ragtime Crawling recording. |
| RecordingService | Record a voice memo until you press Stop. |
| LocationService | Print coordinate updates, including while backgrounded. |
| GeofenceService | Print entry into Apple Park's 200 m circle using CLLocationManagerDelegate. |
| NearbyInteractionService | Print distance to a second phone. |
| PushService | Print when a silent push arrives, then return noData. |

- The tiny draft and cache cleanup aren't endurance tests.
- Continued processing reads as three real steps: downloadVideo, makeThumbnail,
  saveVideo. System progress counts completed steps (0–3), not bytes or estimated
  time. It stays at zero during the download; this is a small teaching example,
  not appropriate progress reporting for arbitrarily long downloads.
- Its expiration handler cancels the Swift task, including the async URLSession
  download. Cancellation is checked between steps; the synchronous file save is
  not interruptible. The catch reports failure for cancellation or other errors.
  Outputs are continued-download.mp4 and continued-thumbnail.jpg in Documents.
- DownloadService remains the background-URLSession example. Prefer that API for
  a file transfer alone; continued processing also allows the subsequent app work.
- Processing deletes one file synchronously on the scheduler queue and completes
  immediately; it has no cancellable ongoing work. Refresh cancels its URLSession task.
- Refresh, processing, and health-research requests are submitted on entering the
  background. Registration stays at launch. iOS chooses when to run them.
  Continued processing stays user-initiated in the foreground.
- Health research needs the `com.apple.developer.backgroundtasks.healthresearch`
  entitlement and participation in a relevant study (see Apple's BGTask.h).
  The service compiles, but this project has NOT been provisioned with that entitlement.
  Submission errors are ignored by the tiny lifecycle example; do not mistake a
  background transition for a successful request. No HealthKit data or actual study
  processing is implemented. The handler only prints and immediately completes.
  Cleanup only has a file to delete after a refresh has actually run.
- Geofencing uses the classic CLLocationManager region delegate: one circle and
  one didEnterRegion callback. No CLMonitor, async event loop, UserDefaults, or
  custom restore routine. The manager/delegate is created at launch so system
  region events can be delivered after relaunch. Grant Always access and cross
  the boundary; starting inside the circle is not an entry event.
- LocationService is separate: startUpdatingLocation delivers coordinates through
  didUpdateLocations. It enables background updates with When In Use access and
  the project's location background mode. Stop it when finished.
- CLMonitor's old "BackgroundWorkFence" name was just an identifier, not a capability;
  its satisfied state meant "inside the circle". This demo no longer uses that API.
- UWB needs two supported phones, tokens exchanged both ways, and its Live Activity.
  Its service now takes the peer's NIDiscoveryToken directly. Share/paste encoding
  lives in DemoListScreen. The service's start function plus distance callback is
  the article example; a real peer token and Live Activity extension remain required.
- Audio/microphone/location Stop methods are demo controls, not background-mode
  prerequisites. Leave them out of the article's startup snippets, but keep the
  buttons so testing doesn't leave recording or location tracking running.
- Stop playback/recording before another audio demo. Downloads can use cellular.
- These are happy-path teaching examples: force unwraps and try! are intentional.
  Refresh reports transport success, not HTTP validity or successful file storage.
  Continued processing reports operation errors but does not validate HTTP status.
  Cache cleanup ignores file errors; downloads don't validate HTTP status.
  UWB assumes supported hardware. These shortcuts are not production error handling.

### Photo credit

Bundled mountain.jpg is the unmodified [Fronalpstock panorama by Hannes Röst](https://commons.wikimedia.org/wiki/File:Fronalpstock_big.jpg),
[CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/).
This photo is retained as an optional sample asset; the current demos do not use it.

## Evidence without service dependencies

Services use ordinary `print`. AppDelegate redirects stdout to Documents/events.txt
so a phone test works without keeping a debugger attached. Use **Read log** or
**Export log**; saved downloads and recordings also appear in Files.

Build/verification evidence is under the local, ignored `verification/` directory.
A successful build is not a successful background-device test. See
`verification/simple-services-verification.txt` for this pass's actual observations.

Signing/account settings were not changed. `project.yml` reflects the source
layout; do not regenerate after changing signing in Xcode without updating it.

`ARTICLE.md` contains the agreed outline. Copy code from the service files rather
than the superseded snippets (preserved locally in `verification/before-minimal/`).
