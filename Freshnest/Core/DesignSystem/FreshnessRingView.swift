import SwiftUI

/// Primary freshness visualization: a progress ring plus the numeric score
/// and an explicit text label, so status is never communicated by color alone.
struct FreshnessRingView: View {
    let score: Int
    let state: FreshnessState
    var diameter: CGFloat = 140

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var clampedScore: Int { min(100, max(0, score)) }

    var body: some View {
        VStack(spacing: FreshnestSpacing.xs) {
            ZStack {
                Circle()
                    .stroke(FreshnestColors.separator, lineWidth: 10)
                Circle()
                    .trim(from: 0, to: CGFloat(clampedScore) / 100)
                    .stroke(
                        FreshnestColors.color(for: state),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(reduceMotion ? nil : .easeInOut, value: clampedScore)

                VStack(spacing: 2) {
                    Text("\(clampedScore)")
                        .font(.system(size: diameter * 0.28, weight: .bold, design: .rounded))
                        .foregroundStyle(FreshnestColors.primaryText)
                    Text("/ 100")
                        .font(.caption)
                        .foregroundStyle(FreshnestColors.secondaryText)
                }
            }
            .frame(width: diameter, height: diameter)

            FreshnessStatusLabel(state: state)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Freshness score \(clampedScore) out of 100, \(state.displayName)"))
    }
}

/// Combines a status dot with text so color-blind users still get the signal.
struct FreshnessStatusLabel: View {
    let state: FreshnessState

    var body: some View {
        HStack(spacing: FreshnestSpacing.xxs) {
            Circle()
                .fill(FreshnestColors.color(for: state))
                .frame(width: 8, height: 8)
            Text(state.displayName)
                .font(FreshnestTypography.secondary.weight(.semibold))
                .foregroundStyle(FreshnestColors.primaryText)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview("Freshness Ring") {
    VStack(spacing: 24) {
        FreshnessRingView(score: 92, state: .veryFresh)
        FreshnessRingView(score: 40, state: .eatToday)
    }
    .padding()
    .background(FreshnestColors.background)
}
