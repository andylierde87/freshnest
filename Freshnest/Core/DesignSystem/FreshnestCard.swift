import SwiftUI

/// The standard quiet, minimal-shadow card container used across Freshnest.
struct FreshnestCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(FreshnestSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(FreshnestColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: FreshnestRadius.card, style: .continuous))
    }
}

/// Constrains content to a comfortable reading width on large iPad screens.
struct ReadableWidthContainer<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        HStack {
            Spacer(minLength: 0)
            content
                .frame(maxWidth: FreshnestLayout.maxReadableWidth)
            Spacer(minLength: 0)
        }
    }
}
