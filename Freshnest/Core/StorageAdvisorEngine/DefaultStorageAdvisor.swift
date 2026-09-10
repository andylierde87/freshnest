import Foundation

/// Deterministic, offline compatibility rules based on each food's bundled
/// ethylene production/sensitivity levels. No network or LLM dependency.
struct DefaultStorageAdvisor: StorageAdvising {

    func advise(for foods: [FoodDefinition]) -> StorageAdvisorResult {
        var seenIDs = Set<String>()
        let uniqueFoods = foods.filter { seenIDs.insert($0.id).inserted }

        guard !uniqueFoods.isEmpty else {
            return StorageAdvisorResult(compatibility: .good, warnings: [], recommendations: [])
        }

        var warnings: [StorageWarning] = []
        for i in 0..<uniqueFoods.count {
            for j in (i + 1)..<uniqueFoods.count {
                if let warning = incompatibilityWarning(uniqueFoods[i], uniqueFoods[j]) {
                    warnings.append(warning)
                }
            }
        }

        let recommendations = uniqueFoods.map { food in
            StorageRecommendation(
                foodID: food.id,
                recommendedStorage: bestStorage(for: food),
                tips: food.storageTips
            )
        }

        let compatibility: StorageCompatibility
        if warnings.isEmpty {
            compatibility = .good
        } else if warnings.count == 1 {
            compatibility = .fair
        } else {
            compatibility = .poor
        }

        return StorageAdvisorResult(compatibility: compatibility, warnings: warnings, recommendations: recommendations)
    }

    private func isProducer(_ level: EthyleneLevel) -> Bool {
        level == .medium || level == .high
    }

    private func isSensitive(_ level: EthyleneLevel) -> Bool {
        level == .medium || level == .high
    }

    private func incompatibilityWarning(_ a: FoodDefinition, _ b: FoodDefinition) -> StorageWarning? {
        let aAffectsB = isProducer(a.ethyleneProduction) && isSensitive(b.ethyleneSensitivity)
        let bAffectsA = isProducer(b.ethyleneProduction) && isSensitive(a.ethyleneSensitivity)

        guard aAffectsB || bAffectsA else { return nil }

        let producer = aAffectsB ? a : b
        let sensitive = aAffectsB ? b : a
        let message = String(
            localized: "\(producer.name) produces ethylene gas, which may speed up ripening or spoilage of \(sensitive.name)."
        )
        return StorageWarning(id: "\(a.id)-\(b.id)", involvedFoodIDs: [a.id, b.id], message: message)
    }

    private func bestStorage(for food: FoodDefinition) -> StorageLocation {
        let candidates: [(StorageLocation, Int)] = [
            (.counter, food.counterShelfLifeDays),
            (.fridge, food.fridgeShelfLifeDays),
        ]
        return candidates.max { $0.1 < $1.1 }?.0 ?? .counter
    }
}
