import HeraldCore

public protocol MixpanelPropertySetterFactory: Sendable {
    func create(_ property: any Property) throws -> Resolution<any MixpanelPropertySetter>
}

/// Asks each factory in order and uses the first answer that isn't `declined`. If all decline,
/// nothing is sent. Stops the app if a ``FallbackFactory`` isn't last.
public struct CompositeMixpanelPropertySetterFactory: MixpanelPropertySetterFactory {
    private let factories: [any MixpanelPropertySetterFactory]

    public init(_ factories: [any MixpanelPropertySetterFactory]) {
        requireFallbackLast(factories)
        self.factories = factories
    }

    public func create(_ property: any Property) throws -> Resolution<any MixpanelPropertySetter> {
        try Resolution.firstOf(factories) { factory in try factory.create(property) }
    }
}
