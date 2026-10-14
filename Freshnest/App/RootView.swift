import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(AppContainer.self) private var container
    @Environment(\.modelContext) private var modelContext
    @State private var didCheckLaunchDecision = false
    @State private var isCheckingLaunchDecision = false

    var body: some View {
        @Bindable var settings = container.settingsStore
        let launchDecision = container.launchDecisionStore.decision
        Group {
            if shouldShowLaunchLoader {
                LaunchLoadingView()
            } else if let url = launchDecision?.url, launchDecision?.flow == .freshnest {
                LaunchWebView(url: url)
            } else if settings.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView {
                    settings.hasCompletedOnboarding = true
                }
            }
        }
        .task {
            #if DEBUG
            if LaunchEnvironment.isUITesting && LaunchEnvironment.seedSampleData {
                SampleDataSeeder.seed(into: modelContext, now: container.clock.now)
            }
            #endif
            guard !LaunchEnvironment.isUITesting else { return }
            guard !didCheckLaunchDecision, container.launchDecisionStore.decision == nil else { return }
            didCheckLaunchDecision = true
            isCheckingLaunchDecision = true
            defer { isCheckingLaunchDecision = false }
            do {
                let decision = try await container.launchClient.fetchDecision()
                container.launchDecisionStore.save(decision)
            } catch {
                // Temporary network failures should not burn in a default state.
            }
        }
    }

    private var shouldShowLaunchLoader: Bool {
        !LaunchEnvironment.isUITesting &&
        (!didCheckLaunchDecision || isCheckingLaunchDecision) &&
        container.launchDecisionStore.decision == nil
    }
}

private struct LaunchLoadingView: View {
    var body: some View {
        ZStack {
            FreshnestColors.background
                .ignoresSafeArea()

            VStack(spacing: FreshnestSpacing.lg) {
                ZStack {
                    Circle()
                        .fill(FreshnestColors.accent.opacity(0.14))
                        .frame(width: 88, height: 88)

                    Image(systemName: "leaf.fill")
                        .font(.system(size: 38, weight: .semibold))
                        .foregroundStyle(FreshnestColors.accent)
                }

                VStack(spacing: FreshnestSpacing.xs) {
                    Text("PantryPulse")
                        .font(FreshnestTypography.sectionTitle)
                        .foregroundStyle(FreshnestColors.primaryText)

                    Text("Checking your pantry")
                        .font(FreshnestTypography.secondary)
                        .foregroundStyle(FreshnestColors.secondaryText)
                }

                ProgressView()
                    .controlSize(.large)
                    .tint(FreshnestColors.accent)
            }
            .padding(FreshnestSpacing.xxl)
            .frame(maxWidth: 280)
            .background(FreshnestColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: FreshnestRadius.card, style: .continuous))
        }
    }
}
