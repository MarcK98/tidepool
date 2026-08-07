import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it } from "vitest";
import App from "../App";
import { filterSpots, SPOTS } from "../data";

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

  it("shows only good and epic spots once the filter is on", async () => {
    render(<App />);
    await userEvent.click(screen.getByRole("button", { name: /good & epic/i }));

    const kept = filterSpots(SPOTS, "goodPlus");
    for (const s of kept) {
      expect(screen.getByTestId(`spot-${s.id}`)).toBeInTheDocument();
    }
    for (const s of SPOTS.filter((s) => !kept.includes(s))) {
      expect(screen.queryByTestId(`spot-${s.id}`)).not.toBeInTheDocument();
    }
    expect(screen.getByText(`${kept.length} of ${SPOTS.length} spots tracked`)).toBeInTheDocument();
  });

  it("switches back to the whole catalogue", async () => {
    render(<App />);
    await userEvent.click(screen.getByRole("button", { name: /good & epic/i }));
    await userEvent.click(screen.getByRole("button", { name: /all spots/i }));

    for (const s of SPOTS) {
      expect(screen.getByTestId(`spot-${s.id}`)).toBeInTheDocument();
    }
    expect(screen.getByText(`${SPOTS.length} spots tracked`)).toBeInTheDocument();
  });

  it("marks the active filter as pressed", async () => {
    render(<App />);
    const all = screen.getByRole("button", { name: /all spots/i });
    const goodPlus = screen.getByRole("button", { name: /good & epic/i });

    expect(all).toHaveAttribute("aria-pressed", "true");
    expect(goodPlus).toHaveAttribute("aria-pressed", "false");

    await userEvent.click(goodPlus);
    expect(all).toHaveAttribute("aria-pressed", "false");
    expect(goodPlus).toHaveAttribute("aria-pressed", "true");
  });
});
