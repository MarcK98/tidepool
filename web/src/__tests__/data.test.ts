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

describe("condition filter", () => {
  it("keeps the whole catalogue on 'all'", () => {
    expect(filterSpots(SPOTS, "all")).toEqual(SPOTS);
  });

  it("keeps only Good and Epic spots on 'goodPlus'", () => {
    const kept = filterSpots(SPOTS, "goodPlus");
    expect(kept.map((s) => rate(s)).every((r) => r === "good" || r === "epic")).toBe(true);
    expect(kept.map((s) => s.id)).toEqual(["hanalei", "raglan", "taghazout", "uluwatu"]);
  });

  it("drops fair and poor spots", () => {
    expect(matchesFilter(spot("ericeira"), "goodPlus")).toBe(false); // fair
    expect(matchesFilter(spot("bundoran"), "goodPlus")).toBe(false); // poor
  });

  it("never keeps more than 'all' does", () => {
    expect(filterSpots(SPOTS, "goodPlus").length).toBeLessThanOrEqual(
      filterSpots(SPOTS, "all").length,
    );
  });
});
