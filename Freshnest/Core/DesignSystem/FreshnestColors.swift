import SwiftUI

/// Central semantic color palette. Feature views must reference these tokens
/// instead of hardcoding RGB values, so Light/Dark Mode and future theming
/// stay consistent.
enum FreshnestColors {
    static let background = Color("Background", bundle: .main)
    static let secondaryBackground = Color("SecondaryBackground", bundle: .main)
    static let cardBackground = Color("CardBackground", bundle: .main)

    static let primaryText = Color("PrimaryText", bundle: .main)
    static let secondaryText = Color("SecondaryText", bundle: .main)
    static let tertiaryText = Color("TertiaryText", bundle: .main)

    static let separator = Color("AppSeparatorColor", bundle: .main)
    static let accent = Color("AccentColor", bundle: .main)

    static let success = Color("SuccessColor", bundle: .main)
    static let warning = Color("WarningColor", bundle: .main)
    static let danger = Color("DangerColor", bundle: .main)

    static let freshnessExcellent = Color("FreshnessExcellent", bundle: .main)
    static let freshnessGood = Color("FreshnessGood", bundle: .main)
    static let freshnessSoon = Color("FreshnessSoon", bundle: .main)
    static let freshnessUrgent = Color("FreshnessUrgent", bundle: .main)

    static func color(for state: FreshnessState) -> Color {
        switch state {
        case .veryFresh: return freshnessExcellent
        case .fresh: return freshnessGood
        case .useSoon: return freshnessSoon
        case .eatToday: return freshnessUrgent
        case .checkCarefully: return danger
        }
    }
}
