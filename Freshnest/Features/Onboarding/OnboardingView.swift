import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let symbolName: String
    let title: String
    let message: String
}

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var pageIndex = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            symbolName: "leaf.fill",
            title: String(localized: "Freshnest"),
            message: String(localized: "Keep your produce fresh longer.")
        ),
        OnboardingPage(
            symbolName: "checklist",
            title: String(localized: "Know what to eat first."),
            message: String(localized: "Freshnest prioritizes produce using storage, ripeness, age, and freshness.")
        ),
        OnboardingPage(
            symbolName: "camera.viewfinder",
            title: String(localized: "Check visible freshness."),
            message: String(localized: "Take a photo to estimate ripeness and visible condition on your device.")
        ),
        OnboardingPage(
            symbolName: "lock.shield",
            title: String(localized: "Private by design."),
            message: String(localized: "No account. No required cloud. No photo uploads.")
        ),
    ]

    var body: some View {
        VStack {
            TabView(selection: $pageIndex) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                        .accessibilityIdentifier("onboarding.page.\(index)")
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button {
                if pageIndex < pages.count - 1 {
                    withAnimation { pageIndex += 1 }
                } else {
                    onFinish()
                }
            } label: {
                Text(pageIndex < pages.count - 1 ? String(localized: "Continue") : String(localized: "Get Started"))
            }
            .buttonStyle(.freshnestPrimary)
            .padding(.horizontal, FreshnestSpacing.md)
            .padding(.bottom, FreshnestSpacing.lg)
            .accessibilityIdentifier("onboarding.continueButton")
        }
        .background(FreshnestColors.background)
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: FreshnestSpacing.xl) {
            Spacer()
            Image(systemName: page.symbolName)
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(FreshnestColors.accent)
                .accessibilityHidden(true)

            VStack(spacing: FreshnestSpacing.sm) {
                Text(page.title)
                    .font(FreshnestTypography.largeTitle)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(FreshnestColors.primaryText)

                Text(page.message)
                    .font(FreshnestTypography.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(FreshnestColors.secondaryText)
            }
            .padding(.horizontal, FreshnestSpacing.xl)
            Spacer()
            Spacer()
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    OnboardingView(onFinish: {})
}
