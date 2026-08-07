<h1 align="center">🌊 Tidepool</h1>
<p align="center"><em>Know the water before you go.</em></p>

Swell, period, wind and the full tide curve for six breaks — on the web and on
your phone, with no ads and no login.

| | |
|---|---|
| **Web** | Vite + React + TypeScript · [staging](https://marck98.github.io/tidepool/) |
| **iOS** | SwiftUI, iOS 17+ |
| **CI** | Web typecheck/test/build + iOS build/test on every PR |

## Quick start

```bash
cd web && npm install && npm run dev      # http://localhost:5173
```

```bash
cd ios
xcodebuild test -project Tidepool.xcodeproj -scheme Tidepool \
  -destination "$(./scripts/simulator-destination.sh)"
```

## How the forecast works

Both clients score a spot the same way: long-period swell earns, wind punishes.

```
score = swell(ft) × 1.1 + period(s) × 0.6 − wind(kt) × 0.5
        ≥12 epic · ≥9 good · ≥6 fair · else poor
```

Tide is a semidiurnal cosine peaking at the spot's high-tide hour (period
≈ 12.42 h), sampled hourly for the chart. Everything is deterministic — there is
no backend, and the same spot always draws the same curve.

> Forecast data is illustrative. Check your local buoy before paddling out.
