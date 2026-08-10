import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it } from "vitest";
import App from "../App";
import { sortSpots, SPOTS } from "../data";

/** The ids of the cards in the order they appear on the page. */
const renderedOrder = () =>
  Array.from(document.querySelectorAll<HTMLElement>("[data-testid^='spot-']")).map(
    (el) => el.dataset.testid!.replace("spot-", ""),
  );

describe("<App />", () => {
  it("leads with the pitch", () => {
    render(<App />);
    expect(screen.getByRole("heading", { level: 1 })).toHaveTextContent(/know the water/i);
  });

  it("renders a card for every spot in the catalogue", () => {
    render(<App />);
    for (const s of SPOTS) {
      expect(screen.getByTestId(`spot-${s.id}`)).toBeInTheDocument();
    }
  });

  it("gives each tide chart an accessible label", () => {
    render(<App />);
    expect(screen.getAllByRole("img", { name: /tide curve/i })).toHaveLength(SPOTS.length);
  });

  it("opens in the catalogue order, with Featured selected", () => {
    render(<App />);
    expect(renderedOrder()).toEqual(SPOTS.map((s) => s.id));
    expect(screen.getByRole("button", { name: /featured/i })).toHaveAttribute(
      "aria-pressed",
      "true",
    );
  });

  it("reorders biggest-swell-first when the toggle is flipped", async () => {
    const user = userEvent.setup();
    render(<App />);

    await user.click(screen.getByRole("button", { name: /biggest swell/i }));

    expect(renderedOrder()).toEqual(sortSpots(SPOTS, "swell").map((s) => s.id));
    expect(screen.getByRole("button", { name: /biggest swell/i })).toHaveAttribute(
      "aria-pressed",
      "true",
    );
  });

  it("flips back to the default order", async () => {
    const user = userEvent.setup();
    render(<App />);

    await user.click(screen.getByRole("button", { name: /biggest swell/i }));
    await user.click(screen.getByRole("button", { name: /featured/i }));

    expect(renderedOrder()).toEqual(SPOTS.map((s) => s.id));
  });
});
