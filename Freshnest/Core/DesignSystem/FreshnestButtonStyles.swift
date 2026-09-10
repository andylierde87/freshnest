import SwiftUI

struct FreshnestPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(FreshnestColors.accent.opacity(configuration.isPressed ? 0.85 : 1))
            .clipShape(RoundedRectangle(cornerRadius: FreshnestRadius.control, style: .continuous))
    }
}

struct FreshnestSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(FreshnestColors.primaryText)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(FreshnestColors.secondaryBackground.opacity(configuration.isPressed ? 0.7 : 1))
            .clipShape(RoundedRectangle(cornerRadius: FreshnestRadius.control, style: .continuous))
    }
}

extension ButtonStyle where Self == FreshnestPrimaryButtonStyle {
    static var freshnestPrimary: FreshnestPrimaryButtonStyle { FreshnestPrimaryButtonStyle() }
}

extension ButtonStyle where Self == FreshnestSecondaryButtonStyle {
    static var freshnestSecondary: FreshnestSecondaryButtonStyle { FreshnestSecondaryButtonStyle() }
}
