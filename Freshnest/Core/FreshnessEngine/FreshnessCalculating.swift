import Foundation

struct ManualCheckInput: Sendable {
    let state: ManualFreshnessCheckState
    let date: Date
}

struct PhotoScanInput: Sendable {
    let score: Int
    let date: Date
}

struct FreshnessInput: Sendable {
    let foodDefinition: FoodDefinition
    let purchaseDate: Date
    let storageLocation: StorageLocation
    let initialRipeness: RipenessState
    let latestManualCheck: ManualCheckInput?
    let latestPhotoScan: PhotoScanInput?
    let currentDate: Date

    init(
        foodDefinition: FoodDefinition,
        purchaseDate: Date,
        storageLocation: StorageLocation,
        initialRipeness: RipenessState,
        latestManualCheck: ManualCheckInput? = nil,
        latestPhotoScan: PhotoScanInput? = nil,
        currentDate: Date
    ) {
        self.foodDefinition = foodDefinition
        self.purchaseDate = purchaseDate
        self.storageLocation = storageLocation
        self.initialRipeness = initialRipeness
        self.latestManualCheck = latestManualCheck
        self.latestPhotoScan = latestPhotoScan
        self.currentDate = currentDate
    }
}

struct FreshnessResult: Sendable, Equatable {
    let score: Int
    let state: FreshnessState
    let estimatedFreshUntil: Date?
}

protocol FreshnessCalculating: Sendable {
    func freshness(for input: FreshnessInput) -> FreshnessResult
}
