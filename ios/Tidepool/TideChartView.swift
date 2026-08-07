import SwiftUI

/// The day's tide as a filled curve — the SwiftUI twin of the web `TideChart`.
struct TideChartView: View {
    let spot: Spot

    var body: some View {
        GeometryReader { geo in
            let curve = spot.tideCurve
            let peak = max(curve.map(abs).max() ?? 1, 0.001)
            let w = geo.size.width
            let h = geo.size.height
            let point: (Int, Double) -> CGPoint = { i, v in
                CGPoint(
                    x: w * CGFloat(i) / CGFloat(curve.count - 1),
                    y: h / 2 - CGFloat(v / peak) * (h / 2 - 6)
                )
            }

            ZStack {
                // Fill under the curve.
                Path { p in
                    p.move(to: CGPoint(x: 0, y: h))
                    for (i, v) in curve.enumerated() { p.addLine(to: point(i, v)) }
                    p.addLine(to: CGPoint(x: w, y: h))
                    p.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [Theme.aqua.opacity(0.42), Theme.aqua.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                // Datum line.
                Path { p in
                    p.move(to: CGPoint(x: 0, y: h / 2))
                    p.addLine(to: CGPoint(x: w, y: h / 2))
                }
                .stroke(Theme.line, style: StrokeStyle(lineWidth: 1, dash: [3, 5]))

                // The curve itself.
                Path { p in
                    for (i, v) in curve.enumerated() {
                        let pt = point(i, v)
                        if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
                    }
                }
                .stroke(Theme.aqua, style: StrokeStyle(lineWidth: 2, lineCap: .round))
            }
        }
        .frame(height: 72)
        .accessibilityElement()
        .accessibilityLabel("Tide curve for \(spot.name), high tide at \(spot.highTideHour):00")
    }
}
