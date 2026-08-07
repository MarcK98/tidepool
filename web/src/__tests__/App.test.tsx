import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import App from "../App";
import { SPOTS } from "../data";

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
});
