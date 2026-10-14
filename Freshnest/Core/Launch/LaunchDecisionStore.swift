import Foundation
import Observation

@Observable
final class LaunchDecisionStore {
    private let defaults: UserDefaults

    private enum Keys {
        static let savedWebURL = "launch.savedWebURL"
        static let pantryState = "launch.pantryState"
    }

    private(set) var decision: LaunchDecision?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        decision = Self.load(from: defaults)
    }

    func save(_ decision: LaunchDecision) {
        self.decision = decision
        switch decision.flow {
        case .freshnest:
            defaults.set(decision.url?.absoluteString, forKey: Keys.savedWebURL)
            defaults.set(0, forKey: Keys.pantryState)
        case .pantry:
            defaults.set(decision.url?.absoluteString, forKey: Keys.savedWebURL)
            defaults.set(1, forKey: Keys.pantryState)
        }
    }

    func clear() {
        defaults.removeObject(forKey: Keys.savedWebURL)
        defaults.removeObject(forKey: Keys.pantryState)
        decision = nil
    }

    private static func load(from defaults: UserDefaults) -> LaunchDecision? {
        guard defaults.object(forKey: Keys.pantryState) != nil else { return nil }
        let flow: LaunchFlow = defaults.integer(forKey: Keys.pantryState) == 0 ? .freshnest : .pantry
        let url = defaults.string(forKey: Keys.savedWebURL).flatMap(URL.init(string:))
        return LaunchDecision(flow: flow, url: url)
    }
}
