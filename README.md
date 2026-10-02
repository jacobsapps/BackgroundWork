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
| ContinuedProcessingService | Compress one bundled photo into Documents/compressed-photo.jpg. |
| AudioService | Play the bundled ragtime Crawling recording. |
| RecordingService | Record a voice memo until you press Stop. |
| GeofenceService | Print inside/outside events for Apple Park's 200 m geofence. |
| NearbyInteractionService | Print distance to a second phone. |
| PushService | Print when a silent push arrives, then return noData. |

- The tiny draft, cache cleanup and single-photo export aren't endurance tests.
  No artificial loops, sleeps or fake progress. The photo reports one completed file.
- Expiration cancels the Swift tasks. Cancellation is cooperative: an in-progress
  synchronous JPEG encode/file operation finishes before completion is reported.
  This is a small example, not an interruptible large-batch processing engine.
- The photo example uses JPEG compression, not GPU filters or Photos access.
- Refresh and processing requests run when iOS chooses, not after a guaranteed delay.
  Run refresh before cleanup to have a cached file to delete.
- Geofencing retains CLMonitor/CLServiceSession and restores monitoring on relaunch.
  Edit the Apple Park coordinates to test near you; initial state isn't an arrival.
- UWB needs two supported phones, tokens exchanged both ways, and its Live Activity.
  Its remaining setup is necessary for this example, not extra sample work.
- Stop playback/recording before another audio demo. Downloads can use cellular.
- These are happy-path teaching examples: force unwraps and try! are intentional.

### Photo credit

Bundled mountain.jpg is the unmodified [Fronalpstock panorama by Hannes Röst](https://commons.wikimedia.org/wiki/File:Fronalpstock_big.jpg),
[CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/).
The exported JPEG is recompressed; retain this attribution and license if sharing it.

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
