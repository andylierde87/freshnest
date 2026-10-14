import Foundation

enum LaunchFlow: String, Codable, Sendable {
    case pantry
    case freshnest
}

struct LaunchDecision: Codable, Equatable, Sendable {
    let flow: LaunchFlow
    let url: URL?

    enum CodingKeys: String, CodingKey {
        case flow = "pantryFlow"
        case url
    }
}

struct LaunchRequest: Encodable, Sendable {
    let appID: String
    let idfv: String?
    let deviceName: String
    let pushToken: String?
    let userAgent: String

    enum CodingKeys: String, CodingKey {
        case appID = "appid"
        case idfv
        case deviceName
        case pushToken
        case userAgent
    }
}
