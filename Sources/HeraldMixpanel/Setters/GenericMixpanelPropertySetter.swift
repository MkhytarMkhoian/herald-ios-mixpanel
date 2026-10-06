import HeraldCore
import Mixpanel

/// Registers `property` as a super property, so Mixpanel attaches it to every later event from
/// this device.
public struct GenericMixpanelPropertySetter: MixpanelPropertySetter {
    private let property: any Property
    private let sdk: any MixpanelSDK

    public init(property: any Property, mixpanel: MixpanelInstance) {
        self.init(property: property, sdk: LiveMixpanelSDK(instance: mixpanel))
    }

    init(property: any Property, sdk: any MixpanelSDK) {
        self.property = property
        self.sdk = sdk
    }

    public func set() {
        sdk.registerSuperProperties([property.name: mixpanelValue(property.value)])
    }
}
