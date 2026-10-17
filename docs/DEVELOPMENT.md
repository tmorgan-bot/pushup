# Development notes

## Scope and decisions

Native SwiftUI, iOS 17+, manual counting, one local user, and a default goal of 50 are starter assumptions. No camera, motion sensing, HealthKit, notifications, or network access is needed. No permissions are requested. Names and UI copy can be changed without changing the storage model.

Keep the current app small: views talk to a single main-actor store, which owns persistence and derived totals. Extract feature views or replace UserDefaults with SwiftData when the product needs justify it. Saved dates use absolute timestamps; daily totals follow the device's current calendar/time zone, so totals can change while travelling. Goals apply to today's progress rather than being stored per historical day.

## Verification checklist

1. Generate the project, build, and run unit tests on macOS.
2. On a simulator: count, undo, save multiple sets, change the goal, delete a set, force quit, and relaunch. Confirm saved history and goal persist.
3. Check large accessibility text, VoiceOver, dark mode, landscape, and iPad. Verify the scroll view keeps counting controls reachable.
4. Confirm a fresh install shows empty history and zero daily progress. Test midnight/time-zone changes.
5. Before distribution: add app icons, choose the final bundle ID and signing team, review privacy disclosures and backup behaviour, and test on a physical device.

## Open product questions

Confirm the intended audience and what “pushup” means. Then decide whether manual counting is sufficient, whether to add training plans, and whether export or sync is needed. These are options, not approved commitments.

## Validation limits

This starter was authored in a Linux environment without Swift, Xcode, or an iOS simulator. Static file checks can verify structure only. A successful macOS build, automated test run, and visual QA are required before treating it as validated for use. CI installs XcodeGen through Homebrew; pin its version when reproducible release builds become necessary.
