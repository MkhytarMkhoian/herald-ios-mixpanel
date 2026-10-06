import Foundation
import HeraldCore
import Mixpanel

@testable import HeraldMixpanel

struct TestEvent: Event {
    let name: String
    var parameters: [String: AnalyticsValue] = [:]
}

struct TestScreenView: ScreenViewEvent {
    let name: String
    var parameters: [String: AnalyticsValue] = [:]
}

struct TestProperty: Property {
    let name: String
    let value: AnalyticsValue
}

struct TestUserProperty: UserProperty {
    let name: String
    let value: AnalyticsValue
}

/// Records the Mixpanel calls instead of making them, each as one line that shows every value's
/// type, like `track checkout seats=Int(3)`. Locked, so any thread can call it: hence
/// `@unchecked Sendable`.
final class RecordingMixpanelSDK: MixpanelSDK, @unchecked Sendable {
    private let lock = NSLock()
    private var recorded: [String] = []

    var calls: [String] {
        lock.lock()
        defer { lock.unlock() }
        return recorded
    }

    func track(event: String, properties: Properties) {
        record("track \(event)\(describe(properties))")
    }

    func registerSuperProperties(_ properties: Properties) {
        record("registerSuperProperties\(describe(properties))")
    }

    func setPeopleProperty(_ property: String, to value: MixpanelType) {
        record("people.set \(property)=\(type(of: value))(\(value))")
    }

    func identify(distinctId: String) { record("identify \(distinctId)") }

    func reset() { record("reset") }

    func flush() { record("flush") }

    func optInTracking() { record("optInTracking") }

    func optOutTracking() { record("optOutTracking") }

    private func describe(_ properties: Properties) -> String {
        var text = ""
        for key in properties.keys.sorted() {
            let value = properties[key]!
            text += " \(key)=\(type(of: value))(\(value))"
        }
        return text
    }

    private func record(_ line: String) {
        lock.lock()
        defer { lock.unlock() }
        recorded.append(line)
    }
}

/// What Herald sent to its error reporter. Locked like ``RecordingMixpanelSDK``.
final class ReportedFailures: @unchecked Sendable {
    private let lock = NSLock()
    private var failures: [AnalyticsFailure] = []

    var all: [AnalyticsFailure] {
        lock.lock()
        defer { lock.unlock() }
        return failures
    }

    func append(_ failure: AnalyticsFailure) {
        lock.lock()
        defer { lock.unlock() }
        failures.append(failure)
    }
}
