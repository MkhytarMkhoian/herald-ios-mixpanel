import HeraldCore
import Mixpanel

/// Sets `property` on the user's People profile.
public struct UserPropertyMixpanelPropertySetter: MixpanelPropertySetter {
    private let property: any UserProperty
    private let sdk: any MixpanelSDK

    public init(property: any UserProperty, mixpanel: MixpanelInstance) {
        self.init(property: property, sdk: LiveMixpanelSDK(instance: mixpanel))
    }

    init(property: any UserProperty, sdk: any MixpanelSDK) {
        self.property = property
        self.sdk = sdk
    }

    public func set() {
        sdk.setPeopleProperty(property.name, to: mixpanelValue(property.value))
    }
}
