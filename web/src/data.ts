// The spot catalogue. Static on purpose: Tidepool's staging build has no
// backend, so the "forecast" is a deterministic function of the spot and the
// hour — the same input always draws the same curve, which keeps screenshots
// and tests stable.

export type Spot = {
  id: string;
  name: string;
  region: string;
  swellFt: number;
  periodSec: number;
  windKts: number;
  windDir: string;
  waterTempF: number;
  /** Metres above chart datum at the day's high tide. */
  highTideM: number;
  /** Hour (0–23, local) the high tide lands on. */
  highTideHour: number;
};

export const SPOTS: Spot[] = [
  {
    id: "hanalei",
    name: "Hanalei Bay",
    region: "Kauaʻi, HI",
    swellFt: 4.5,
    periodSec: 14,
    windKts: 6,
    windDir: "SSE",
    waterTempF: 78,
    highTideM: 0.7,
    highTideHour: 7,
  },
  {
    id: "ericeira",
    name: "Ribeira d'Ilhas",
    region: "Ericeira, PT",
    swellFt: 6.2,
    periodSec: 12,
    windKts: 11,
    windDir: "NNE",
    waterTempF: 63,
    highTideM: 3.1,
    highTideHour: 9,
  },
  {
    id: "raglan",
    name: "Manu Bay",
    region: "Raglan, NZ",
    swellFt: 5.0,
    periodSec: 15,
    windKts: 8,
    windDir: "SW",
    waterTempF: 61,
    highTideM: 2.4,
    highTideHour: 11,
  },
  {
    id: "taghazout",
    name: "Anchor Point",
    region: "Taghazout, MA",
    swellFt: 7.4,
    periodSec: 16,
    windKts: 5,
    windDir: "NE",
    waterTempF: 68,
    highTideM: 2.0,
    highTideHour: 6,
  },
  {
    id: "bundoran",
    name: "The Peak",
    region: "Bundoran, IE",
    swellFt: 3.1,
    periodSec: 9,
    windKts: 19,
    windDir: "W",
    waterTempF: 54,
    highTideM: 3.8,
    highTideHour: 13,
  },
  {
    id: "uluwatu",
    name: "Uluwatu",
    region: "Bali, ID",
    swellFt: 8.0,
    periodSec: 17,
    windKts: 7,
    windDir: "ESE",
    waterTempF: 82,
    highTideM: 2.2,
    highTideHour: 10,
  },
];

export type Rating = "epic" | "good" | "fair" | "poor";

/**
 * One word for the whole forecast. Long-period swell with light wind is the
 * thing surfers actually care about, so the score leans on period and punishes
 * wind hard — 20kts flattens even a great swell.
 */
export function rate(spot: Spot): Rating {
  const score = spot.swellFt * 1.1 + spot.periodSec * 0.6 - spot.windKts * 0.5;
  if (score >= 12) return "epic";
  if (score >= 9) return "good";
  if (score >= 6) return "fair";
  return "poor";
}

export const RATING_LABEL: Record<Rating, string> = {
  epic: "Epic",
  good: "Good",
  fair: "Fair",
  poor: "Poor",
};

/** Which spots the list shows. Mirrored by `ConditionsFilter` on iOS. */
export type ConditionsFilter = "all" | "goodPlus";

export const CONDITIONS_FILTERS: { id: ConditionsFilter; label: string }[] = [
  { id: "all", label: "All spots" },
  { id: "goodPlus", label: "Good & Epic" },
];

/** Ratings a spot may hold and still survive each filter. */
const FILTER_RATINGS: Record<ConditionsFilter, Rating[]> = {
  all: ["epic", "good", "fair", "poor"],
  goodPlus: ["epic", "good"],
};

export function matchesFilter(spot: Spot, filter: ConditionsFilter): boolean {
  return FILTER_RATINGS[filter].includes(rate(spot));
}

export function filterSpots(spots: Spot[], filter: ConditionsFilter): Spot[] {
  return spots.filter((spot) => matchesFilter(spot, filter));
}

/**
 * Tide height in metres at `hour`, as a smooth semidiurnal curve peaking at the
 * spot's high tide. Two highs and two lows a day (period ≈ 12.42h).
 */
export function tideAt(spot: Spot, hour: number): number {
  const phase = ((hour - spot.highTideHour) / 12.42) * 2 * Math.PI;
  return Number((spot.highTideM * Math.cos(phase)).toFixed(2));
}

/** The 24 hourly samples the chart draws. */
export function tideCurve(spot: Spot): number[] {
  return Array.from({ length: 24 }, (_, h) => tideAt(spot, h));
}
