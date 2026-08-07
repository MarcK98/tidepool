import SwiftUI

struct SpotCardView: View {
    let spot: Spot

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(spot.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Theme.text)
                    Text(spot.region)
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.muted)
                }
                Spacer(minLength: 8)
                Text(spot.rating.label.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.7)
                    .foregroundStyle(Theme.tint(for: spot.rating))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Theme.tint(for: spot.rating).opacity(0.16), in: Capsule())
                    .accessibilityIdentifier("rating-\(spot.id)")
            }

            HStack(spacing: 0) {
                stat("swell", String(format: "%.1f ft", spot.swellFt))
                stat("period", "\(spot.periodSec) s")
                stat("wind", "\(spot.windKts) kt \(spot.windDir)")
                stat("water", "\(spot.waterTempF)°F")
            }

            TideChartView(spot: spot)

            Text(String(format: "High tide %02d:00 · %.1f m", spot.highTideHour, spot.highTideM))
                .font(.system(size: 12))
                .foregroundStyle(Theme.muted)
        }
        .padding(16)
        .background(Theme.ink2, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Theme.line, lineWidth: 1)
        )
        .accessibilityIdentifier("spot-\(spot.id)")
    }

    private func stat(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(Theme.text)
            Text(label.uppercased())
                .font(.system(size: 10))
                .tracking(0.8)
                .foregroundStyle(Theme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
