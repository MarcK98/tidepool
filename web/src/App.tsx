import { useState } from "react";
import { CONDITION_FILTERS, SPOTS, filterSpots, type ConditionFilter } from "./data";
import { SpotCard } from "./components/SpotCard";

export default function App() {
  const [filter, setFilter] = useState<ConditionFilter>("all");
  const visible = filterSpots(SPOTS, filter);

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
            <p>
              {filter === "all"
                ? `${SPOTS.length} spots tracked`
                : `${visible.length} of ${SPOTS.length} spots firing`}
            </p>
          </div>
          <div className="filter" role="group" aria-label="Filter spots by conditions">
            {CONDITION_FILTERS.map((f) => (
              <button
                key={f.id}
                type="button"
                className={`chip${filter === f.id ? " is-on" : ""}`}
                aria-pressed={filter === f.id}
                data-testid={`filter-${f.id}`}
                onClick={() => setFilter(f.id)}
              >
                {f.label}
              </button>
            ))}
          </div>
        </div>
        <div className="grid">
          {visible.map((spot) => (
            <SpotCard key={spot.id} spot={spot} />
          ))}
        </div>
        {visible.length === 0 && (
          <p className="empty">Nothing firing right now — check back on the next swell.</p>
        )}
      </section>

      <footer className="foot">
        <span>Tidepool</span>
        <span>Forecast data is illustrative — check your local buoy before paddling out.</span>
      </footer>
    </div>
  );
}
