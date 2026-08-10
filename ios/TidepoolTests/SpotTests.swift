import XCTest
@testable import Tidepool

final class SpotTests: XCTestCase {
    private func spot(_ id: String) throws -> Spot {
        try XCTUnwrap(SpotCatalogue.all.first { $0.id == id }, "no fixture spot \(id)")
    }

    func testEpicRatingForLongPeriodLightWind() throws {
        XCTAssertEqual(try spot("uluwatu").rating, .epic)
    }

    func testWindRuinsAnOtherwiseFineSwell() throws {
        XCTAssertEqual(try spot("bundoran").rating, .poor)
    }

    /// More wind must never improve a rating — the property, not one example.
    func testRatingIsMonotonicInWind() throws {
        let order = Rating.allCases.reversed().map(\.self) // poor … epic
        let base = try spot("raglan")
        let calm = Spot(id: base.id, name: base.name, region: base.region,
                        swellFt: base.swellFt, periodSec: base.periodSec, windKts: 0,
                        windDir: base.windDir, waterTempF: base.waterTempF,
                        highTideM: base.highTideM, highTideHour: base.highTideHour)
        let blown = Spot(id: base.id, name: base.name, region: base.region,
                         swellFt: base.swellFt, periodSec: base.periodSec, windKts: 30,
                         windDir: base.windDir, waterTempF: base.waterTempF,
                         highTideM: base.highTideM, highTideHour: base.highTideHour)
        let calmIdx = try XCTUnwrap(order.firstIndex(of: calm.rating))
        let blownIdx = try XCTUnwrap(order.firstIndex(of: blown.rating))
        XCTAssertGreaterThanOrEqual(calmIdx, blownIdx)
    }

    func testTidePeaksAtHighTideHour() throws {
        let s = try spot("ericeira")
        XCTAssertEqual(s.tide(at: Double(s.highTideHour)), s.highTideM, accuracy: 0.01)
    }

    func testTideIsLowSixHoursLater() throws {
        let s = try spot("ericeira")
        XCTAssertLessThan(s.tide(at: Double(s.highTideHour) + 6.21), -s.highTideM * 0.9)
    }

    func testTideCurveHasOneSamplePerHour() throws {
        XCTAssertEqual(try spot("hanalei").tideCurve.count, 24)
    }

    func testFeaturedSortLeavesTheCatalogueOrderAlone() {
        XCTAssertEqual(SpotCatalogue.all.sorted(by: .featured).map(\.id),
                       SpotCatalogue.all.map(\.id))
    }

    func testSwellSortPutsTheBiggestSwellFirst() throws {
        let swells = SpotCatalogue.all.sorted(by: .swell).map(\.swellFt)
        XCTAssertEqual(swells.first, SpotCatalogue.all.map(\.swellFt).max())
        XCTAssertEqual(swells, swells.sorted(by: >))
    }

    /// Ties must fall back to catalogue order — the web does the same, and
    /// `sorted` alone is not stable.
    func testSwellSortBreaksTiesByCatalogueOrder() throws {
        let base = try spot("hanalei")
        let tied = ["a", "b", "c"].enumerated().map { index, id in
            Spot(id: id, name: base.name, region: base.region,
                 swellFt: id == "c" ? 9 : 5, periodSec: base.periodSec,
                 windKts: base.windKts, windDir: base.windDir,
                 waterTempF: base.waterTempF, highTideM: base.highTideM,
                 highTideHour: base.highTideHour + index)
        }
        XCTAssertEqual(tied.sorted(by: .swell).map(\.id), ["c", "a", "b"])
    }

    func testSortKeepsEverySpot() {
        XCTAssertEqual(Set(SpotCatalogue.all.sorted(by: .swell).map(\.id)),
                       Set(SpotCatalogue.all.map(\.id)))
    }

    func testCatalogueIdsAreUnique() {
        XCTAssertEqual(Set(SpotCatalogue.all.map(\.id)).count, SpotCatalogue.all.count)
    }

    /// The two clients ship the same catalogue; a spot added to one and not the
    /// other is the drift this guards against.
    func testCatalogueIsNotEmpty() {
        XCTAssertEqual(SpotCatalogue.all.count, 6)
    }
}
