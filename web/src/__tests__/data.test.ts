import { describe, expect, it } from "vitest";
import { rate, sortSpots, SPOTS, tideAt, tideCurve } from "../data";

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

describe("sortSpots", () => {
  it("leaves the catalogue order alone when featured", () => {
    expect(sortSpots(SPOTS, "featured").map((s) => s.id)).toEqual(SPOTS.map((s) => s.id));
  });

  it("puts the biggest swell first", () => {
    const swells = sortSpots(SPOTS, "swell").map((s) => s.swellFt);
    expect(swells[0]).toBe(Math.max(...SPOTS.map((s) => s.swellFt)));
    expect(swells).toEqual([...swells].sort((a, b) => b - a));
  });

  it("breaks ties by catalogue order rather than platform whim", () => {
    const tied = [
      { ...spot("hanalei"), id: "a", swellFt: 5 },
      { ...spot("hanalei"), id: "b", swellFt: 5 },
      { ...spot("hanalei"), id: "c", swellFt: 9 },
    ];
    expect(sortSpots(tied, "swell").map((s) => s.id)).toEqual(["c", "a", "b"]);
  });

  it("keeps every spot and does not mutate the catalogue", () => {
    const before = SPOTS.map((s) => s.id);
    expect(sortSpots(SPOTS, "swell")).toHaveLength(SPOTS.length);
    expect(SPOTS.map((s) => s.id)).toEqual(before);
  });
});

describe("catalogue", () => {
  it("has unique spot ids", () => {
    expect(new Set(SPOTS.map((s) => s.id)).size).toBe(SPOTS.length);
  });
});
