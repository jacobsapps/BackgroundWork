# Background runtime experiment

Separate probe app; the article services are not instrumented.

## Question

Under a documented device state, how much background execution does a user-started
BGContinuedProcessingTask receive compared with UIApplication.beginBackgroundTask?
This does not establish a universal iOS timeout.

## Workload

Release build. One utility-queue worker repeatedly JPEG-encodes the same bundled
10109 × 4542 image at quality 0.5, up to 100,000 images, discarding each output after
counting bytes. This is deliberately a synthetic CPU/memory benchmark, not a real
photo library or a timer kept alive with fake progress. Each progress unit is a
completed encode. The two APIs run identical work. No background audio, location,
network traffic, detached debugger, simulated expiration, or external keep-alive.

Both modes have a **two-hour observation cap from worker start**. Progress uses the
finite batch count, not estimated time; this progress profile is part of the test
condition, and results should not be generalised to other progress profiles.

## Protocol

1. Sign/install on the physical phone. Use Release; launch without attaching LLDB.
2. Record device model and full OS build externally. Each run logs OS version,
   initial battery/charging state, Low Power Mode, and thermal state.
3. Start a mode with its button, then immediately go Home. Do not force-quit.
4. Keep foreground use consistent (Home, screen unlocked; auto-lock may occur and
   must be noted), charging unchanged, and other heavy workloads stopped.
5. Leave untouched until expiration or the cap. Do not reopen the probe to inspect
   progress mid-run. Copy Documents logs with devicectl after observation.
6. Let the phone cool to nominal. Repeat three times per mode, alternating modes.
7. Report individual observations and range/median only where expiration was
   actually observed. Device cap/success results are censored, not timeout values.

Launch without debugger:

```sh
xcrun devicectl device process launch --device DEVICE com.jacob.BackgroundWork.RuntimeProbe uikit
# or replace uikit with continued
```

Logs: Files → Runtime Probe. One JSONL file per run; checkpoints approximately every
five seconds (after the current encode). Monotonic elapsed time and time since first
background entry, completed images, thermal state, and terminal events are recorded.
File writes are synchronised; this small identical logging cost exists in both modes.

## Interpretation

- `expiration`: iOS called the expiration handler. Measure backgroundSeconds here.
  For continued processing, user cancellation uses this callback too: exclude any
  run where someone pressed Cancel in the system UI.
- `observation_cutoff`: at least the logged duration, NOT the API's upper limit.
- `batchCompleted: true`: successful work completion, NOT a time limit.
- Log stops without a terminal event: unresolved suspension/termination. Inspect
  process/crash evidence; last checkpoint isn't automatically an expiration time.
- Foreground reentry, user_stop, charging changes, or interference: annotate or
  discard the run rather than treating it as a clean background measurement.
- An encode in flight is synchronous and cannot be interrupted; cancellation is
  checked between encodes. UIKit releases its assertion immediately on expiration.
  Continued processing reports completion after the current encode returns.

## Current status

Device discovered: Jacob's physical iPhone 17, iOS 27.0 build 24A5380h.
Device build currently blocked: Xcode reports No Accounts for configured team
TG6SK4A998, so it cannot create this app's development provisioning profile.
No accounts changed. Select the correct Jacob team in Xcode and unlock the phone.
Simulator smoke checks validate plumbing only; they are NOT device runtime results.

The cap was increased from 30 minutes to two hours on 2026-10-05 at Jacob’s request. Earlier logs retain their original cutoffSeconds value. Installing the new build starts a separate trial; do not combine runtimes. The preceding mostly-locked trial included a user-reported unlock.
