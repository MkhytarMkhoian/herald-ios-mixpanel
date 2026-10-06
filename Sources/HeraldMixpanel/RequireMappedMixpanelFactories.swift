import HeraldCore

/// Fails for any event that reaches it, so the error reporter shows events nobody mapped. Put it
/// last in a chain.
public struct RequireMappedMixpanelEventTrackerFactory: MixpanelEventTrackerFactory,
    FallbackFactory
{
    public init() {}

    public func create(_ event: any Event) throws -> Resolution<any MixpanelEventTracker> {
        throw UnhandledEventError(event: event)
    }
}

public struct RequireMappedMixpanelPropertySetterFactory: MixpanelPropertySetterFactory,
    FallbackFactory
{
    public init() {}

    public func create(_ property: any Property) throws -> Resolution<any MixpanelPropertySetter> {
        throw UnhandledPropertyError(property: property)
    }
}
