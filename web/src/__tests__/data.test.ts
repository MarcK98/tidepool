import { describe, expect, it } from "vitest";
import { filterSpots, matchesFilter, rate, SPOTS, tideAt, tideCurve } from "../data";

const spot = (id: string) => {
  const found = SPOTS.find((s) => s.id === id);
  if (!found) throw new Error(`no fixture spot ${id}`);
  return found;
};

describe("rate", () => {
  it("calls long-period, light-wind swell epic", () => {
    expect(rate(spot("uluwatu"))).toBe("epic");
  });

  it("punishes wind — Bundoran's 19kt onshore is not surfable", () => {
    expect(rate(spot("bundoran"))).toBe("poor");
  });

  it("is monotonic in wind: more wind never improves a rating", () => {
    const order = ["poor", "fair", "good", "epic"];
    const base = spot("raglan");
    const calm = order.indexOf(rate({ ...base, windKts: 0 }));
    const blown = order.indexOf(rate({ ...base, windKts: 30 }));
    expect(calm).toBeGreaterThanOrEqual(blown);
  });
});

describe("tide model", () => {
  it("peaks at the spot's high-tide hour", () => {
    const s = spot("ericeira");
    expect(tideAt(s, s.highTideHour)).toBeCloseTo(s.highTideM, 2);
  });

  it("is near its low roughly six hours later", () => {
    const s = spot("ericeira");
    expect(tideAt(s, s.highTideHour + 6.21)).toBeLessThan(-s.highTideM * 0.9);
  });

  it("samples one point per hour of the day", () => {
    expect(tideCurve(spot("hanalei"))).toHaveLength(24);
  });
});

describe("catalogue", () => {
  it("has unique spot ids", () => {
    expect(new Set(SPOTS.map((s) => s.id)).size).toBe(SPOTS.length);
  });
});

describe("conditions filter", () => {
  it("keeps the whole catalogue under 'all'", () => {
    expect(filterSpots(SPOTS, "all")).toEqual(SPOTS);
  });

  it("keeps only good and epic spots under 'goodPlus'", () => {
    const kept = filterSpots(SPOTS, "goodPlus");
    expect(kept.length).toBeGreaterThan(0);
    expect(kept.map((s) => rate(s)).every((r) => r === "good" || r === "epic")).toBe(true);
  });

  it("drops the flat spots — Bundoran is poor, so it is filtered out", () => {
    expect(matchesFilter(spot("bundoran"), "all")).toBe(true);
    expect(matchesFilter(spot("bundoran"), "goodPlus")).toBe(false);
  });

  it("keeps an epic spot under both filters", () => {
    expect(matchesFilter(spot("uluwatu"), "all")).toBe(true);
    expect(matchesFilter(spot("uluwatu"), "goodPlus")).toBe(true);
  });

  it("preserves catalogue order", () => {
    const kept = filterSpots(SPOTS, "goodPlus").map((s) => s.id);
    const expected = SPOTS.filter((s) => kept.includes(s.id)).map((s) => s.id);
    expect(kept).toEqual(expected);
  });
});
