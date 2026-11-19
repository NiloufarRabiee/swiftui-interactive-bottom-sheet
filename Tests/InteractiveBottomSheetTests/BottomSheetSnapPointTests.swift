import XCTest
@testable import InteractiveBottomSheet

final class BottomSheetSnapPointTests: XCTestCase {
    private let sizing = BottomSheetSizing(
        collapsedHeight: 112,
        mediumFraction: 0.5,
        topInset: 24
    )

    func testDetentHeightsAreOrdered() {
        let collapsed = sizing.height(for: .collapsed, availableHeight: 800)
        let medium = sizing.height(for: .medium, availableHeight: 800)
        let expanded = sizing.height(for: .expanded, availableHeight: 800)

        XCTAssertEqual(collapsed, 112)
        XCTAssertEqual(medium, 388)
        XCTAssertEqual(expanded, 776)
        XCTAssertLessThan(collapsed, medium)
        XCTAssertLessThan(medium, expanded)
    }

    func testHeightsStayWithinSmallContainer() {
        for point in BottomSheetSnapPoint.allCases {
            let height = sizing.height(for: point, availableHeight: 80)
            XCTAssertGreaterThanOrEqual(height, 0)
            XCTAssertLessThanOrEqual(height, 80)
        }
    }

    func testInvalidInputsCannotProduceNaN() {
        let unusual = BottomSheetSizing(
            collapsedHeight: .nan,
            mediumFraction: .infinity,
            topInset: -.infinity
        )
        for point in BottomSheetSnapPoint.allCases {
            let height = unusual.height(for: point, availableHeight: .nan)
            XCTAssertTrue(height.isFinite)
            XCTAssertEqual(height, 0)
        }
    }

    func testFractionIsClamped() {
        let high = BottomSheetSizing(mediumFraction: 9, topInset: 0)
        let low = BottomSheetSizing(mediumFraction: -2, topInset: 0)
        XCTAssertEqual(high.height(for: .medium, availableHeight: 500), 500)
        XCTAssertEqual(low.height(for: .medium, availableHeight: 500), 112)
    }

    func testUpwardPredictedDragExpandsSheet() {
        XCTAssertEqual(
            sizing.target(
                from: .medium,
                predictedEndTranslation: -440,
                availableHeight: 800
            ),
            .expanded
        )
    }

    func testDownwardPredictedDragCollapsesSheet() {
        XCTAssertEqual(
            sizing.target(
                from: .medium,
                predictedEndTranslation: 440,
                availableHeight: 800
            ),
            .collapsed
        )
    }

    func testSmallDragKeepsCurrentDetent() {
        XCTAssertEqual(
            sizing.target(
                from: .medium,
                predictedEndTranslation: 8,
                availableHeight: 800
            ),
            .medium
        )
    }

    func testCollapsedGeometryKeepsCurrentPositionOnTie() {
        XCTAssertEqual(
            sizing.target(
                from: .medium,
                predictedEndTranslation: 0,
                availableHeight: 20
            ),
            .medium
        )
    }

    func testNonFinitePredictionKeepsCurrentPosition() {
        XCTAssertEqual(
            sizing.target(
                from: .medium,
                predictedEndTranslation: .nan,
                availableHeight: 800
            ),
            .medium
        )
    }

    func testAccessibleNavigationStopsAtBoundaries() {
        XCTAssertEqual(BottomSheetSnapPoint.collapsed.lower, .collapsed)
        XCTAssertEqual(BottomSheetSnapPoint.collapsed.higher, .medium)
        XCTAssertEqual(BottomSheetSnapPoint.medium.higher, .expanded)
        XCTAssertEqual(BottomSheetSnapPoint.expanded.higher, .expanded)
        XCTAssertEqual(BottomSheetSnapPoint.expanded.lower, .medium)
    }
}
