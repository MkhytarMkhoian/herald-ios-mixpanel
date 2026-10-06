import HeraldCore

/// Sends events and properties to Mixpanel, as its factory chains decide. The calls for one event
/// run in order, and if one fails the rest don't run. Anything no factory claims isn't sent.
///
/// ```swift
/// let tracker = MixpanelAnalyticsTrackerService(
///     eventTrackerFactory: CompositeMixpanelEventTrackerFactory([
///         ScreenViewMixpanelEventTrackerFactory(sdk: mixpanel),
///         GenericMixpanelEventTrackerFactory(sdk: mixpanel),
///     ]),
///     propertySetterFactory: CompositeMixpanelPropertySetterFactory([
///         UserPropertyMixpanelPropertySetterFactory(sdk: mixpanel),  // the People profile
///         GenericMixpanelPropertySetterFactory(sdk: mixpanel),  // super properties
///     ])
/// )
/// ```
public struct MixpanelAnalyticsTrackerService: EventTrackerService, PropertyTrackerService {
    private let eventTrackerFactory: any MixpanelEventTrackerFactory
    private let propertySetterFactory: any MixpanelPropertySetterFactory

    public init(
        eventTrackerFactory: any MixpanelEventTrackerFactory,
        propertySetterFactory: any MixpanelPropertySetterFactory
    ) {
        self.eventTrackerFactory = eventTrackerFactory
        self.propertySetterFactory = propertySetterFactory
    }

    public func track(_ event: any Event) {
        do {
            for tracker in try eventTrackerFactory.create(event).handlers() {
                try tracker.track()
            }
        } catch {
            Herald.reportFailure(error)
        }
    }

    public func set(_ property: any Property) {
        do {
            for setter in try propertySetterFactory.create(property).handlers() {
                try setter.set()
            }
        } catch {
            Herald.reportFailure(error)
        }
    }
}
