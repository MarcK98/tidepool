import { rate, RATING_LABEL, type Spot } from "../data";
import { TideChart } from "./TideChart";

const Stat = ({ label, value }: { label: string; value: string }) => (
  <div className="stat">
    <span className="stat-value">{value}</span>
    <span className="stat-label">{label}</span>
  </div>
);

export function SpotCard({ spot }: { spot: Spot }) {
  const rating = rate(spot);
  return (
    <article className="card" data-testid={`spot-${spot.id}`}>
      <header className="card-head">
        <div>
          <h3>{spot.name}</h3>
          <p className="region">{spot.region}</p>
        </div>
        <span className={`badge badge-${rating}`}>{RATING_LABEL[rating]}</span>
      </header>

      <div className="stats">
        <Stat label="swell" value={`${spot.swellFt.toFixed(1)} ft`} />
        <Stat label="period" value={`${spot.periodSec} s`} />
        <Stat label="wind" value={`${spot.windKts} kt ${spot.windDir}`} />
        <Stat label="water" value={`${spot.waterTempF}°F`} />
      </div>

      <TideChart spot={spot} />
      <p className="tide-note">
        High tide {String(spot.highTideHour).padStart(2, "0")}:00 · {spot.highTideM.toFixed(1)} m
      </p>
    </article>
  );
}
