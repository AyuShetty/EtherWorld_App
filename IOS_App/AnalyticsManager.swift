import Foundation

enum AnalyticsEvent: String {
    case appOpen
    case articleOpen
    case articleSave
    case share
    case notificationReceived
}

final class AnalyticsManager {
    static let shared = AnalyticsManager()
    private init() {}

    private var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "analyticsEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "analyticsEnabled") }
    }

    func log(_ event: AnalyticsEvent, params: [String: Any] = [:]) {
        guard isEnabled else { return }
        #if DEBUG
        print("[Analytics] \(event.rawValue): \(params)")
        #endif
        // Hook for SDKs like Firebase Analytics or TelemetryDeck
    }
}
