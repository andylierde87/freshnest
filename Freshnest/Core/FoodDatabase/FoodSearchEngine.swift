import Foundation

/// Case-insensitive, alias-aware search over a list of `FoodDefinition`s.
/// Pure and stateless so it is trivially unit-testable.
enum FoodSearchEngine {
    static func search(_ query: String, in definitions: [FoodDefinition]) -> [FoodDefinition] {
        let normalizedQuery = normalize(query)
        guard !normalizedQuery.isEmpty else { return [] }

        var scored: [(definition: FoodDefinition, rank: Int)] = []

        for definition in definitions {
            guard let rank = matchRank(query: normalizedQuery, definition: definition) else { continue }
            scored.append((definition, rank))
        }

        return scored
            .sorted { lhs, rhs in
                if lhs.rank != rhs.rank { return lhs.rank < rhs.rank }
                return lhs.definition.name < rhs.definition.name
            }
            .map(\.definition)
    }

    /// Lower rank = better match. Returns nil when there is no match at all.
    private static func matchRank(query: String, definition: FoodDefinition) -> Int? {
        let name = normalize(definition.name)
        let aliases = definition.aliases.map(normalize)
        let candidates = [name] + aliases

        if name == query { return 0 }
        if aliases.contains(query) { return 1 }
        if name.hasPrefix(query) { return 2 }
        if aliases.contains(where: { $0.hasPrefix(query) }) { return 3 }
        if candidates.contains(where: { $0.contains(query) }) { return 4 }
        return nil
    }

    private static func normalize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}
