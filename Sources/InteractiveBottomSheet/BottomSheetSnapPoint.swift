import Foundation

/// The three supported resting positions of an interactive bottom sheet.
public enum BottomSheetSnapPoint: Int, CaseIterable, Equatable, Sendable {
    case collapsed
    case medium
    case expanded

    /// The next larger snap point, or the current one at the upper bound.
    public var higher: Self {
        Self(rawValue: min(rawValue + 1, Self.expanded.rawValue)) ?? self
    }

    /// The next smaller snap point, or the current one at the lower bound.
    public var lower: Self {
        Self(rawValue: max(rawValue - 1, Self.collapsed.rawValue)) ?? self
    }

    public var accessibilityTitle: String {
        switch self {
        case .collapsed: return "Collapsed"
        case .medium: return "Half expanded"
        case .expanded: return "Expanded"
        }
    }
}

/// Testable, UI-independent dimensions and snap-selection policy.
/// Measurements are in points. Positive drag translation means dragging down.
public struct BottomSheetSizing: Equatable, Sendable {
    public var collapsedHeight: Double
    public var mediumFraction: Double
    public var topInset: Double

    public init(
        collapsedHeight: Double = 112,
        mediumFraction: Double = 0.5,
        topInset: Double = 16
    ) {
        self.collapsedHeight = collapsedHeight
        self.mediumFraction = mediumFraction
        self.topInset = topInset
    }

    /// Returns a bounded height for the selected position and container height.
    public func height(
        for point: BottomSheetSnapPoint,
        availableHeight: Double
    ) -> Double {
        let available = Self.nonNegativeFinite(availableHeight)
        let expanded = max(0, available - Self.nonNegativeFinite(topInset))
        let collapsed = min(expanded, Self.nonNegativeFinite(collapsedHeight))
        let fraction = min(1, Self.nonNegativeFinite(mediumFraction))
        let medium = min(expanded, max(collapsed, expanded * fraction))

        switch point {
        case .collapsed: return collapsed
        case .medium: return medium
        case .expanded: return expanded
        }
    }

    /// Finds the closest snap position after the drag's predicted end.
    /// Keeps the current position if candidates are tied.
    public func target(
        from current: BottomSheetSnapPoint,
        predictedEndTranslation: Double,
        availableHeight: Double
    ) -> BottomSheetSnapPoint {
        let translation = predictedEndTranslation.isFinite
            ? predictedEndTranslation : 0
        let projectedHeight = height(for: current, availableHeight: availableHeight)
            - translation

        var best = current
        var bestDistance = abs(
            height(for: current, availableHeight: availableHeight) - projectedHeight
        )

        for candidate in BottomSheetSnapPoint.allCases where candidate != current {
            let distance = abs(
                height(for: candidate, availableHeight: availableHeight) - projectedHeight
            )
            if distance + 0.000_001 < bestDistance {
                best = candidate
                bestDistance = distance
            }
        }

        return best
    }

    private static func nonNegativeFinite(_ value: Double) -> Double {
        value.isFinite ? max(0, value) : 0
    }
}
