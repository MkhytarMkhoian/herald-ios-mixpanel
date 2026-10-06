import HeraldCore
import Mixpanel

public struct GenericMixpanelEventTracker: MixpanelEventTracker {
    private let event: any Event
    private let sdk: any MixpanelSDK

    public init(event: any Event, mixpanel: MixpanelInstance) {
        self.init(event: event, sdk: LiveMixpanelSDK(instance: mixpanel))
    }

    init(event: any Event, sdk: any MixpanelSDK) {
        self.event = event
        self.sdk = sdk
    }

    public func track() {
        sdk.track(event: event.name, properties: mixpanelProperties(event.parameters))
    }
}
