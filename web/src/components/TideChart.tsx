import { tideCurve, type Spot } from "../data";

const W = 320;
const H = 88;

/**
 * The day's tide as a filled curve. Drawn straight from the model rather than
 * a charting library — 24 points don't justify the dependency, and hand-rolled
 * SVG keeps the gradient consistent with the rest of the page.
 */
export function TideChart({ spot }: { spot: Spot }) {
  const curve = tideCurve(spot);
  const max = Math.max(...curve.map(Math.abs)) || 1;
  const x = (i: number) => (i / (curve.length - 1)) * W;
  const y = (v: number) => H / 2 - (v / max) * (H / 2 - 8);

  const line = curve.map((v, i) => `${i === 0 ? "M" : "L"}${x(i).toFixed(1)},${y(v).toFixed(1)}`).join(" ");
  const area = `${line} L${W},${H} L0,${H} Z`;

  return (
    <svg
      className="tide-chart"
      viewBox={`0 0 ${W} ${H}`}
      role="img"
      aria-label={`Tide curve for ${spot.name}, high tide at ${spot.highTideHour}:00`}
    >
      <defs>
        <linearGradient id={`fill-${spot.id}`} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor="#3ddad7" stopOpacity="0.42" />
          <stop offset="100%" stopColor="#3ddad7" stopOpacity="0" />
        </linearGradient>
      </defs>
      <line className="tide-axis" x1="0" y1={H / 2} x2={W} y2={H / 2} />
      <path d={area} fill={`url(#fill-${spot.id})`} />
      <path className="tide-line" d={line} />
    </svg>
  );
}
