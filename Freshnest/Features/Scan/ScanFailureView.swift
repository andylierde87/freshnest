import SwiftUI

struct ScanFailureView: View {
    let message: String
    let onRetry: () -> Void
    let onManual: () -> Void

    var body: some View {
        VStack(spacing: FreshnestSpacing.lg) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(FreshnestColors.warning)

            Text(message)
                .font(FreshnestTypography.cardTitle)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("scan.failureMessage")

            VStack(alignment: .leading, spacing: 4) {
                Label("One item visible", systemImage: "checkmark")
                Label("Good lighting", systemImage: "checkmark")
                Label("No packaging", systemImage: "checkmark")
                Label("The full produce item inside the frame", systemImage: "checkmark")
            }
            .font(FreshnestTypography.secondary)
            .foregroundStyle(FreshnestColors.secondaryText)

            Button("Scan Again", action: onRetry)
                .buttonStyle(.freshnestPrimary)
                .padding(.horizontal, FreshnestSpacing.xxl)
                .accessibilityIdentifier("scan.failure.retryButton")

            Button("Select Manually", action: onManual)
                .buttonStyle(.freshnestSecondary)
                .padding(.horizontal, FreshnestSpacing.xxl)
                .accessibilityIdentifier("scan.failure.selectManuallyButton")

            Spacer()
        }
        .padding()
        .background(FreshnestColors.background)
    }
}
