import Foundation
import SwiftData
@testable import Freshnest

enum InMemoryContainer {
    @MainActor
    static func make() -> ModelContainer {
        ModelContainerFactory.makeContainer(inMemory: true)
    }
}
