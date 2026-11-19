// Copy this file into an iOS App target that links the local package.
// Remove the starter app's existing @main declaration first.
import SwiftUI
import InteractiveBottomSheet

@main
struct BottomSheetDemoApp: App {
    var body: some Scene {
        WindowGroup {
            BottomSheetDemoScreen()
        }
    }
}

private struct BottomSheetDemoScreen: View {
    @State private var position: BottomSheetSnapPoint = .medium

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.25, blue: 0.48),
                    Color(red: 0.28, green: 0.47, blue: 0.68)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                Text("Daily SwiftUI Lab")
                    .font(.footnote.weight(.semibold))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.8))

                Text("A panel that\nmoves with you.")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                Text("Drag the grabber, tap it, or use the controls.")
                    .foregroundStyle(.white.opacity(0.85))

                Picker("Sheet position", selection: $position) {
                    Text("Low").tag(BottomSheetSnapPoint.collapsed)
                    Text("Half").tag(BottomSheetSnapPoint.medium)
                    Text("Full").tag(BottomSheetSnapPoint.expanded)
                }
                .pickerStyle(.segmented)
                .padding(.top, 12)

                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)

            InteractiveBottomSheet(snapPoint: $position, showsBackdrop: false) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Explore places")
                            .font(.title2.bold())

                        Text("A scrollable list stays independent of the sheet's grabber gesture.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        ForEach(1...8, id: \.self) { item in
                            HStack(spacing: 14) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.indigo)
                                    .frame(width: 36, height: 36)
                                    .background(Color.indigo.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))

                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Place \(item)")
                                        .font(.headline)
                                    Text("Interactive design sample")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(12)
                            .background(
                                Color.primary.opacity(0.04),
                                in: RoundedRectangle(cornerRadius: 14)
                            )
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 28)
                }
            }
        }
    }
}
