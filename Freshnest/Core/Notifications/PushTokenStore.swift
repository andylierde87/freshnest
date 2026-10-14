import Foundation

actor PushTokenStore {
    static let shared = PushTokenStore()

    private let defaults = UserDefaults.standard
    private let key = "push.fcmToken"
    private var token: String?
    private var pendingContinuation: CheckedContinuation<String?, Never>?

    private init() {
        token = defaults.string(forKey: key)
    }

    func setToken(_ token: String?) {
        self.token = token
        defaults.set(token, forKey: key)
        guard let continuation = pendingContinuation else { return }
        pendingContinuation = nil
        continuation.resume(returning: token)
    }

    func waitForToken(timeout: TimeInterval) async -> String? {
        if let token { return token }

        return await withCheckedContinuation { continuation in
            pendingContinuation = continuation
            Task {
                try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                self.resolveTimeoutIfStillPending()
            }
        }
    }

    private func resolveTimeoutIfStillPending() {
        guard let continuation = pendingContinuation else { return }
        pendingContinuation = nil
        continuation.resume(returning: nil)
    }
}
