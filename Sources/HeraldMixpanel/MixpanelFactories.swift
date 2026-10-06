import HeraldCore
import Mixpanel

/// Tracks any event under its own name, with its parameters. Claims every event, so it goes last
/// in a chain.
public struct GenericMixpanelEventTrackerFactory: MixpanelEventTrackerFactory, FallbackFactory {
    private let sdk: any MixpanelSDK

    public init(mixpanel: MixpanelInstance) {
        self.init(sdk: LiveMixpanelSDK(instance: mixpanel))
    }

    init(sdk: any MixpanelSDK) {
        self.sdk = sdk
    }

    public func create(_ event: any Event) -> Resolution<any MixpanelEventTracker> {
        .claimed([GenericMixpanelEventTracker(event: event, sdk: sdk)])
    }
}

/// Claims every ``ScreenViewEvent`` as a `screen_view` event and declines everything else. To send
/// screen views differently, put your own factory before this one.
public struct ScreenViewMixpanelEventTrackerFactory: MixpanelEventTrackerFactory {
    private let sdk: any MixpanelSDK

    public init(mixpanel: MixpanelInstance) {
        self.init(sdk: LiveMixpanelSDK(instance: mixpanel))
    }

    init(sdk: any MixpanelSDK) {
        self.sdk = sdk
    }

    public func create(_ event: any Event) -> Resolution<any MixpanelEventTracker> {
        if let screenView = event as? any ScreenViewEvent {
            return .claimed([ScreenViewMixpanelEventTracker(event: screenView, sdk: sdk)])
        }
        return .declined
    }
}

/// Claims every ``UserProperty`` for the People profile and declines everything else.
///
/// Put it before ``GenericMixpanelPropertySetterFactory``: a ``UserProperty`` is also a
/// ``Property``, so the generic factory would take it first and the profile would never be
/// written.
public struct UserPropertyMixpanelPropertySetterFactory: MixpanelPropertySetterFactory {
    private let sdk: any MixpanelSDK

    public init(mixpanel: MixpanelInstance) {
        self.init(sdk: LiveMixpanelSDK(instance: mixpanel))
    }

    init(sdk: any MixpanelSDK) {
        self.sdk = sdk
    }

    public func create(_ property: any Property) -> Resolution<any MixpanelPropertySetter> {
        if let userProperty = property as? any UserProperty {
            return .claimed([
                UserPropertyMixpanelPropertySetter(property: userProperty, sdk: sdk)
            ])
        }
        return .declined
    }
}

/// Sends every property as a super property. Claims every property, so it goes last in a chain.
public struct GenericMixpanelPropertySetterFactory: MixpanelPropertySetterFactory, FallbackFactory {
    private let sdk: any MixpanelSDK

    public init(mixpanel: MixpanelInstance) {
        self.init(sdk: LiveMixpanelSDK(instance: mixpanel))
    }

    init(sdk: any MixpanelSDK) {
        self.sdk = sdk
    }

    public func create(_ property: any Property) -> Resolution<any MixpanelPropertySetter> {
        .claimed([GenericMixpanelPropertySetter(property: property, sdk: sdk)])
    }
}
