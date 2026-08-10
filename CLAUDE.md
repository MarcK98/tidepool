# Tidepool

Surf and tide conditions for the breaks people actually surf. Two clients, one
catalogue: a React marketing/forecast site and a SwiftUI iPhone app.

```
web/   Vite + React + TypeScript. Tests: vitest (jsdom).
ios/   SwiftUI app, XcodeGen-generated project. Tests: XCTest.
```

## The one rule that matters

`web/src/data.ts` and `ios/Tidepool/Spot.swift` hold **the same catalogue and the
same forecast maths**. They are read side by side on screen. Change one and you
change the other, in the same commit, or the two clients disagree in front of a
viewer.

## Working here

- **Both clients or neither.** A user-visible change lands on web *and* iOS.
- **Verify what you changed, in the thing you changed it in.** Run the web app
  and look at it in Chrome; build the iOS app and drive it in the Simulator.
  Screenshots beat assertions that a build succeeded.
- **Tests are the contract.** `web/src/__tests__/` and `ios/TidepoolTests/`
  mirror each other. A new rule in the forecast model gets a case in both.
- **Ship a PR, never a push to `main`.** Branch, commit, `gh pr create`. `main`
  is what staging deploys from.

## Commands

```bash
# Web
cd web && npm install
npm run dev          # http://localhost:5173
npm test             # vitest
npm run typecheck
npm run build

# iOS
cd ios
./scripts/simulator-destination.sh                     # prints a destination that exists
xcodebuild test -project Tidepool.xcodeproj -scheme Tidepool \
  -destination "$(./scripts/simulator-destination.sh)"
xcodegen generate --spec project.yml                   # only after editing project.yml
```

Never hard-code a simulator name in a command or a workflow — `name=iPhone 16
Pro` resolves the OS to `latest` and fails outright when the newest installed
runtime has no such device. Use the script.

## CI

- **CI** (`.github/workflows/ci.yml`) — web typecheck + tests + build, iOS build
  + unit tests. Runs on every branch and PR. It must be green before a merge.
- **Deploy Staging** (`.github/workflows/deploy-staging.yml`) — builds the web
  bundle, publishes it to GitHub Pages, then announces the release. Triggered by
  hand (`gh workflow run "Deploy Staging"`) or by a push to `main`.

The announcement has two halves, and the deploy is green whether or not either
one lands:

| | Needs | Fires |
|---|---|---|
| `release-notice` artifact → desktop banner | nothing | always |
| Release email | `MAIL_USERNAME` + `MAIL_PASSWORD` secrets | only when both are set |

The artifact is the machine-readable notice (build, Pages URL, sha, run URL).
Run `./scripts/watch-staging.sh` on a Mac to poll for the next completed deploy
and raise a notification from it; `./scripts/notify-mac.sh --demo` shows what
that banner looks like without deploying anything.
