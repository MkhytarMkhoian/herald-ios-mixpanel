import HeraldCore

/// Decides what Mixpanel gets for an event: `claimed` with the calls to make, `dropped` to send
/// nothing, or `declined` to let the next factory decide.
public protocol MixpanelEventTrackerFactory: Sendable {
    func create(_ event: any Event) throws -> Resolution<any MixpanelEventTracker>
}

/// Asks each factory in order and uses the first answer that isn't `declined`. If all decline,
/// nothing is sent. Stops the app if a ``FallbackFactory`` isn't last.
public struct CompositeMixpanelEventTrackerFactory: MixpanelEventTrackerFactory {
    private let factories: [any MixpanelEventTrackerFactory]

    public init(_ factories: [any MixpanelEventTrackerFactory]) {
        requireFallbackLast(factories)
        self.factories = factories
    }

    public func create(_ event: any Event) throws -> Resolution<any MixpanelEventTracker> {
        try Resolution.firstOf(factories) { factory in try factory.create(event) }
    }
}
