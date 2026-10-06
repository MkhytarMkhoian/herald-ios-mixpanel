import Mixpanel

/// The Mixpanel calls this module makes, so the tests can record them instead:
/// ``LiveMixpanelSDK`` in the app, a recorder in the tests.
protocol MixpanelSDK: Sendable {
    func track(event: String, properties: Properties)
    func registerSuperProperties(_ properties: Properties)
    func setPeopleProperty(_ property: String, to value: MixpanelType)
    func identify(distinctId: String)
    func reset()
    func flush()
    func optInTracking()
    func optOutTracking()
}

/// Forwards each call to the app's `MixpanelInstance`.
///
/// Mixpanel does its work on its own queue and is safe to call from any thread, but its instance
/// isn't marked `Sendable`: hence `@unchecked Sendable`.
struct LiveMixpanelSDK: MixpanelSDK, @unchecked Sendable {
    let instance: MixpanelInstance

    func track(event: String, properties: Properties) {
        instance.track(event: event, properties: properties)
    }

    func registerSuperProperties(_ properties: Properties) {
        instance.registerSuperProperties(properties)
    }

    func setPeopleProperty(_ property: String, to value: MixpanelType) {
        instance.people.set(property: property, to: value)
    }

    func identify(distinctId: String) {
        instance.identify(distinctId: distinctId)
    }

    func reset() {
        instance.reset()
    }

    func flush() {
        instance.flush()
    }

    func optInTracking() {
        instance.optInTracking()
    }

    func optOutTracking() {
        instance.optOutTracking()
    }
}
