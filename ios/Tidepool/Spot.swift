import Foundation

/// A break Tidepool tracks. Deliberately the same shape and the same numbers as
/// `web/src/data.ts` — the two clients are supposed to agree on screen, and a
/// drifting catalogue is the first thing a viewer would notice.
struct Spot: Identifiable, Hashable {
    let id: String
    let name: String
    let region: String
    let swellFt: Double
    let periodSec: Int
    let windKts: Int
    let windDir: String
    let waterTempF: Int
    /// Metres above chart datum at the day's high tide.
    let highTideM: Double
    /// Hour (0–23, local) the high tide lands on.
    let highTideHour: Int
}

enum Rating: String, CaseIterable {
    case epic, good, fair, poor

    var label: String {
        switch self {
        case .epic: return "Epic"
        case .good: return "Good"
        case .fair: return "Fair"
        case .poor: return "Poor"
        }
    }
}

/// Which slice of the catalogue the spot list is showing. Mirrors
/// `ConditionFilter` in `web/src/data.ts`.
enum ConditionFilter: String, CaseIterable, Identifiable {
    case all, goodPlus

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: return "All spots"
        case .goodPlus: return "Good & Epic"
        }
    }

    func matches(_ spot: Spot) -> Bool {
        switch self {
        case .all: return true
        case .goodPlus: return Rating.worthIt.contains(spot.rating)
        }
    }
}

extension Rating {
    /// The ratings worth paddling out for — what `.goodPlus` keeps.
    static let worthIt: [Rating] = [.epic, .good]
}

extension Spot {
    /// One word for the whole forecast. Long-period swell with light wind is the
    /// thing surfers actually care about, so the score leans on period and
    /// punishes wind hard — 20kts flattens even a great swell.
    var rating: Rating {
        let score = swellFt * 1.1 + Double(periodSec) * 0.6 - Double(windKts) * 0.5
        if score >= 12 { return .epic }
        if score >= 9 { return .good }
        if score >= 6 { return .fair }
        return .poor
    }

    /// Tide height in metres at `hour`, as a smooth semidiurnal curve peaking at
    /// the spot's high tide. Two highs and two lows a day (period ≈ 12.42h).
    func tide(at hour: Double) -> Double {
        let phase = ((hour - Double(highTideHour)) / 12.42) * 2 * .pi
        return highTideM * cos(phase)
    }

    /// The 24 hourly samples the chart draws.
    var tideCurve: [Double] {
        (0..<24).map { tide(at: Double($0)) }
    }
}

enum SpotCatalogue {
    static let all: [Spot] = [
        Spot(id: "hanalei", name: "Hanalei Bay", region: "Kauaʻi, HI",
             swellFt: 4.5, periodSec: 14, windKts: 6, windDir: "SSE",
             waterTempF: 78, highTideM: 0.7, highTideHour: 7),
        Spot(id: "ericeira", name: "Ribeira d'Ilhas", region: "Ericeira, PT",
             swellFt: 6.2, periodSec: 12, windKts: 11, windDir: "NNE",
             waterTempF: 63, highTideM: 3.1, highTideHour: 9),
        Spot(id: "raglan", name: "Manu Bay", region: "Raglan, NZ",
             swellFt: 5.0, periodSec: 15, windKts: 8, windDir: "SW",
             waterTempF: 61, highTideM: 2.4, highTideHour: 11),
        Spot(id: "taghazout", name: "Anchor Point", region: "Taghazout, MA",
             swellFt: 7.4, periodSec: 16, windKts: 5, windDir: "NE",
             waterTempF: 68, highTideM: 2.0, highTideHour: 6),
        Spot(id: "bundoran", name: "The Peak", region: "Bundoran, IE",
             swellFt: 3.1, periodSec: 9, windKts: 19, windDir: "W",
             waterTempF: 54, highTideM: 3.8, highTideHour: 13),
        Spot(id: "uluwatu", name: "Uluwatu", region: "Bali, ID",
             swellFt: 8.0, periodSec: 17, windKts: 7, windDir: "ESE",
             waterTempF: 82, highTideM: 2.2, highTideHour: 10),
    ]

    static func spots(matching filter: ConditionFilter) -> [Spot] {
        all.filter(filter.matches)
    }
}
