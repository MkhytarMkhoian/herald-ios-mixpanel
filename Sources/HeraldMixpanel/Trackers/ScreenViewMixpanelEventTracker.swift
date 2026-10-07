import HeraldCore
import Mixpanel

/// Tracks `event` as a `screen_view` event, with its name as `screen_name`: the names GA4 uses,
/// since Mixpanel has none of its own.
///
/// Throws if the event has its own `screen_name` parameter, because it would replace the screen's
/// name.
public struct ScreenViewMixpanelEventTracker: MixpanelEventTracker {
    private let event: any ScreenViewEvent
    private let sdk: any MixpanelSDK

    public init(event: any ScreenViewEvent, mixpanel: MixpanelInstance) {
        self.init(event: event, sdk: LiveMixpanelSDK(instance: mixpanel))
    }

    init(event: any ScreenViewEvent, sdk: any MixpanelSDK) {
        self.event = event
        self.sdk = sdk
    }

    public func track() throws {
        var properties = event.parameters.toMixpanelProperties()
        if properties["screen_name"] != nil {
            throw MixpanelRefusal(
                description: "Screen view '\(event.name)' can't have a 'screen_name' parameter: "
                    + "it holds the screen's name.")
        }
        properties["screen_name"] = event.name
        sdk.track(event: "screen_view", properties: properties)
    }
}
