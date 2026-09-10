# Freshnest

Offline-first iOS utility for tracking the freshness of fruits and vegetables at home. See `Freshnest_Development_Spec.md` (provided separately) for the full product specification.

## Requirements

- Xcode 26 (or newer), iOS 18 SDK
- No third-party dependencies — the project has zero Swift Package Manager packages

## Project layout

```
Freshnest/            App target (SwiftUI + SwiftData)
  App/                Entry point, DI container, router, root/tab views
  Core/                Design system, persistence, ML, notifications, engines
  Features/           One folder per feature (Home, Kitchen, Scan, Rescue, ...)
  Models/             Domain enums, FoodDefinition, SwiftData @Model classes
  Resources/          Bundled food + recipe JSON database, asset catalog
FreshnestTests/        XCTest unit tests for the business-logic engines
FreshnestUITests/      XCUITest end-to-end tests for critical user flows
codemagic.yaml         Codemagic CI configuration (tests + App Store build)
```

## Building locally

```bash
xcodebuild -project Freshnest.xcodeproj -scheme Freshnest \
  -destination 'generic/platform=iOS Simulator' build
```

## Running tests

```bash
# Unit tests
xcodebuild -project Freshnest.xcodeproj -scheme Freshnest \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:FreshnestTests test

# UI tests
xcodebuild -project Freshnest.xcodeproj -scheme Freshnest \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:FreshnestUITests test

# iPad layout tests
xcodebuild -project Freshnest.xcodeproj -scheme Freshnest \
  -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5)' \
  -only-testing:FreshnestUITests/iPadLayoutUITests test
```

## Codemagic

`codemagic.yaml` defines three workflows:

- `freshnest-tests` — unit + UI tests on an iPhone simulator (runs on every push).
- `freshnest-ipad-tests` — the iPad-specific layout UI tests.
- `freshnest-release` — signs and archives a build for TestFlight. Requires an
  `app_store_connect` integration named `mainKey` to be
  configured in the Codemagic team settings (API key + issuer ID), plus
  automatic code signing certificates/profiles managed by Codemagic.

## Notes on the ML pipeline

`FoodClassifying` (Vision's on-device image classifier mapped to the bundled
food database) and `FreshnessAnalyzing` (a deterministic, pixel-based visible
condition heuristic — see `HeuristicFreshnessAnalyzer`) are both defined as
protocols so a trained Core ML model can be dropped in later behind the same
interface without touching any call site. Fakes for both live behind
`#if DEBUG` and are only ever selected via explicit launch arguments, never in
a Release build.
