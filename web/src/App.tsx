import { useState } from "react";
import { SORT_LABEL, SORT_MODES, SPOTS, sortSpots, type SortMode } from "./data";
import { SpotCard } from "./components/SpotCard";

export default function App() {
  const [sort, setSort] = useState<SortMode>("featured");
  const spots = sortSpots(SPOTS, sort);

  return (
    <div className="page">
      <div className="glow" aria-hidden="true" />

      <header className="masthead">
        <div className="wordmark">
          <span className="mark" aria-hidden="true" />
          Tidepool
        </div>
        <nav>
          <a href="#spots">Spots</a>
          <a href="https://github.com/MarcK98/tidepool">GitHub</a>
        </nav>
      </header>

      <section className="hero">
        <p className="eyebrow">Surf &amp; tide forecast</p>
        <h1>
          Know the water
          <br />
          before you go.
        </h1>
        <p className="lede">
          Swell, period, wind and the full tide curve for the breaks you actually
          surf — one screen, no ads, no login.
        </p>
        <div className="cta">
          <a className="btn primary" href="#spots">
            Browse spots
          </a>
          <a className="btn ghost" href="#spots">
            Get the iOS app
          </a>
        </div>
      </section>

      <section className="spots" id="spots">
        <div className="section-head">
          <div>
            <h2>Today&apos;s conditions</h2>
            <p>{SPOTS.length} spots tracked</p>
          </div>
          <div className="sort" role="group" aria-label="Sort spots">
            {SORT_MODES.map((mode) => (
              <button
                key={mode}
                type="button"
                className="sort-option"
                aria-pressed={sort === mode}
                onClick={() => setSort(mode)}
              >
                {SORT_LABEL[mode]}
              </button>
            ))}
          </div>
        </div>
        <div className="grid">
          {spots.map((spot) => (
            <SpotCard key={spot.id} spot={spot} />
          ))}
        </div>
      </section>

      <footer className="foot">
        <span>Tidepool</span>
        <span>Forecast data is illustrative — check your local buoy before paddling out.</span>
      </footer>
    </div>
  );
}
