import Foundation
import UIKit
import WebKit

protocol LaunchDecisionFetching: Sendable {
    func fetchDecision() async throws -> LaunchDecision
}

struct RemoteLaunchClient: LaunchDecisionFetching {
    var endpoint = URL(string: "https://frshnest.xyz/api/freshnest-launch")!
    private let pushTokenTimeout: TimeInterval = 3

    func fetchDecision() async throws -> LaunchDecision {
        async let pushToken = PushTokenStore.shared.waitForToken(timeout: pushTokenTimeout)
        async let userAgent = webUserAgent()

        let request = LaunchRequest(
            appID: Bundle.main.bundleIdentifier ?? "com.pantrypulse.ios",
            idfv: await identifierForVendor(),
            deviceName: deviceName(),
            pushToken: await pushToken,
            userAgent: await userAgent
        )

        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(LaunchDecision.self, from: data)
    }

    @MainActor
    private func identifierForVendor() -> String? {
        UIDevice.current.identifierForVendor?.uuidString
    }

    @MainActor
    private func webUserAgent() async -> String {
        await withCheckedContinuation { continuation in
            WKWebView().evaluateJavaScript("navigator.userAgent") { value, _ in
                continuation.resume(returning: value as? String ?? "")
            }
        }
    }

    private func deviceName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        return mirror.children.reduce(into: "") { result, element in
            guard let value = element.value as? Int8, value != 0 else { return }
            result.append(String(UnicodeScalar(UInt8(value))))
        }
    }
}
