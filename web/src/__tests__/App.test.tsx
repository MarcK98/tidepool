import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it } from "vitest";
import App from "../App";
import { SPOTS, rate } from "../data";

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

  it("hides anything below Good once the conditions filter is on", async () => {
    const user = userEvent.setup();
    render(<App />);

    await user.click(screen.getByTestId("filter-goodPlus"));

    for (const s of SPOTS) {
      const rating = rate(s);
      const card = screen.queryByTestId(`spot-${s.id}`);
      if (rating === "epic" || rating === "good") {
        expect(card, `${s.name} is ${rating} and should stay`).toBeInTheDocument();
      } else {
        expect(card, `${s.name} is ${rating} and should be hidden`).not.toBeInTheDocument();
      }
    }
  });

  it("switches back to the whole catalogue", async () => {
    const user = userEvent.setup();
    render(<App />);

    await user.click(screen.getByTestId("filter-goodPlus"));
    await user.click(screen.getByTestId("filter-all"));

    for (const s of SPOTS) {
      expect(screen.getByTestId(`spot-${s.id}`)).toBeInTheDocument();
    }
    expect(screen.getByText(`${SPOTS.length} spots tracked`)).toBeInTheDocument();
  });

  it("marks the active filter as pressed", async () => {
    const user = userEvent.setup();
    render(<App />);

    expect(screen.getByTestId("filter-all")).toHaveAttribute("aria-pressed", "true");
    await user.click(screen.getByTestId("filter-goodPlus"));
    expect(screen.getByTestId("filter-all")).toHaveAttribute("aria-pressed", "false");
    expect(screen.getByTestId("filter-goodPlus")).toHaveAttribute("aria-pressed", "true");
  });
});
