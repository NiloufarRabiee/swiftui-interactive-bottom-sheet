#if canImport(SwiftUI)
import SwiftUI

/// A reusable bottom panel whose grabber controls three snap positions.
/// Put this view in a ZStack or overlay that fills the intended available area.
/// Only the grabber owns a drag gesture, preserving scrolling in sheet content.
public struct InteractiveBottomSheet<SheetContent: View>: View {
    @Binding private var snapPoint: BottomSheetSnapPoint

    private let sizing: BottomSheetSizing
    private let showsBackdrop: Bool
    private let sheetContent: SheetContent

    @GestureState private var dragTranslation: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        snapPoint: Binding<BottomSheetSnapPoint>,
        sizing: BottomSheetSizing = BottomSheetSizing(),
        showsBackdrop: Bool = true,
        @ViewBuilder content: () -> SheetContent
    ) {
        self._snapPoint = snapPoint
        self.sizing = sizing
        self.showsBackdrop = showsBackdrop
        self.sheetContent = content()
    }

    public var body: some View {
        GeometryReader { geometry in
            let available = Double(geometry.size.height)
            let collapsed = sizing.height(
                for: .collapsed, availableHeight: available
            )
            let expanded = sizing.height(
                for: .expanded, availableHeight: available
            )
            let selected = sizing.height(
                for: snapPoint, availableHeight: available
            )
            let visibleHeight = min(
                expanded,
                max(collapsed, selected - Double(dragTranslation))
            )

            ZStack(alignment: .bottom) {
                if showsBackdrop && snapPoint != .collapsed {
                    Color.black.opacity(0.16)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture { setSnapPoint(.collapsed) }
                        .accessibilityLabel("Collapse bottom sheet")
                        .accessibilityAddTraits(.isButton)
                }

                VStack(spacing: 0) {
                    grabber(availableHeight: available)
                    sheetContent
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .top
                        )
                }
                .frame(maxWidth: .infinity)
                .frame(height: CGFloat(visibleHeight), alignment: .top)
                .background(
                    .regularMaterial,
                    in: RoundedRectangle(
                        cornerRadius: 24,
                        style: .continuous
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                }
                .shadow(
                    color: .black.opacity(0.16),
                    radius: 22,
                    x: 0,
                    y: -4
                )
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height,
                alignment: .bottom
            )
        }
    }

    private func grabber(availableHeight: Double) -> some View {
        VStack(spacing: 7) {
            Capsule()
                .fill(Color.secondary.opacity(0.55))
                .frame(width: 42, height: 5)

            Text("DRAG TO RESIZE")
                .font(.system(size: 10, weight: .semibold))
                .tracking(1.2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 4)
                .updating($dragTranslation) { value, state, _ in
                    state = value.translation.height
                }
                .onEnded { value in
                    let destination = sizing.target(
                        from: snapPoint,
                        predictedEndTranslation: Double(
                            value.predictedEndTranslation.height
                        ),
                        availableHeight: availableHeight
                    )
                    setSnapPoint(destination)
                }
        )
        .onTapGesture {
            setSnapPoint(snapPoint == .expanded ? .collapsed : snapPoint.higher)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Bottom sheet position")
        .accessibilityValue(snapPoint.accessibilityTitle)
        .accessibilityHint("Swipe up to expand or down to collapse.")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: setSnapPoint(snapPoint.higher)
            case .decrement: setSnapPoint(snapPoint.lower)
            @unknown default: break
            }
        }
    }

    private func setSnapPoint(_ destination: BottomSheetSnapPoint) {
        withAnimation(
            reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.87)
        ) {
            snapPoint = destination
        }
    }
}
#endif
