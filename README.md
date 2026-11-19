# Interactive Bottom Sheet — Daily SwiftUI Lab

A reusable, educational **SwiftUI bottom sheet** with a draggable grabber, three snap points, spring transitions, and accessible controls.

**Created by Niloufar Rabiee** · [Portfolio](https://niloufarrabieeusa.com) · [GitHub](https://github.com/NiloufarRabiee)

> A small, focused interaction-design study. This is a custom SwiftUI component, not a replacement for Apple's system sheet or a production-tested accessibility solution.

## Features

- Three positions: **collapsed**, **medium**, and **expanded**
- Drag to resize, using `DragGesture` and predicted end translation
- Adaptive height calculations, with safe bounds for small containers
- Spring animation, respecting **Reduce Motion**
- VoiceOver adjustable grabber (swipe up/down), plus tap-to-cycle
- Optional dimmed backdrop with tap-to-collapse
- Drag gesture attached **only to the grabber**, so embedded scroll views keep scrolling
- Pure, deterministic snapping logic with unit tests

## Requirements

- Swift 5.9+, Xcode 15+
- iOS 16+ (macOS 13+ when embedded in a compatible SwiftUI host)
- No third-party dependencies

## Open and test

1. Clone this repository and open **Package.swift** in Xcode.
2. Select the package test scheme and run **Product → Test** (`⌘U`).
3. For a live iPhone demo, create a new **iOS App** in Xcode, add this repository as a **local Swift package** (`File → Add Package Dependencies → Add Local…`), and replace your app's generated `@main` app and content view with [Examples/BottomSheetDemoApp.swift](Examples/BottomSheetDemoApp.swift). Remove the starter app's existing `@main` declaration to avoid duplication.
4. Run the app in an iOS simulator. Drag the capsule at the top of the sheet, tap the capsule, or use the segmented position picker.

The package tests can also run with `swift test`. On Linux, the SwiftUI view is conditionally excluded; tests cover the portable snapping algorithm, **not** iOS rendering.

## Use in your own SwiftUI app

```swift
import SwiftUI
import InteractiveBottomSheet

struct MyScreen: View {
    @State private var position: BottomSheetSnapPoint = .medium

    var body: some View {
        ZStack {
            Color.blue.opacity(0.15).ignoresSafeArea()

            InteractiveBottomSheet(snapPoint: $position) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Explore").font(.title.bold())
                        Text("Drag the handle to resize this panel.")
                    }
                    .padding()
                }
            }
        }
    }
}
```

### Customize sizing

```swift
InteractiveBottomSheet(
    snapPoint: $position,
    sizing: BottomSheetSizing(
        collapsedHeight: 128,
        mediumFraction: 0.55,
        topInset: 20
    ),
    showsBackdrop: true
) {
    MyPanelContent()
}
```

The sizing values use points for heights/insets and a 0–1 fraction for the medium snap point. All snap heights are clamped to the actual available container height.

## Architecture

```text
Package.swift
Sources/InteractiveBottomSheet/
  BottomSheetSnapPoint.swift    # Pure sizing, snap-selection policy
  InteractiveBottomSheet.swift  # SwiftUI presentation + gestures + accessibility
Tests/InteractiveBottomSheetTests/
  BottomSheetSnapPointTests.swift
Examples/
  BottomSheetDemoApp.swift      # Standalone example to add to an Xcode app
.github/workflows/ci.yml        # Swift package tests on macOS
```

**Interaction model:** While the user drags, the visible sheet height is clamped to the collapsed/expanded range. On release, projected translation selects the nearest snap point; tie-breaking keeps the current point. Collapsed/expanded transitions are animated unless Reduce Motion is enabled.

## Scope and known limitations

- The **grabber**, not the entire sheet surface, handles drag gestures. This intentionally avoids interfering with scrollable content.
- It does not implement nested scroll/drag handoff, keyboard-aware repositioning, or custom detent counts.
- Appearance and VoiceOver operation should be checked on real iOS hardware before product use.
- The sample has no separate Xcode project file; it is meant to be copied into a new iOS App target.

## Learning outcomes

`@GestureState` · `DragGesture` · `GeometryReader` · `@Binding` · `withAnimation` · `accessibilityAdjustableAction` · testable interaction state.

## License

MIT — see [LICENSE](LICENSE).

© 2026 Niloufar Rabiee.
