import HeraldCore
import Mixpanel

/// Mixpanel's lifecycle, identity and consent, over the `MixpanelInstance` the app has created.
///
/// `start` doesn't opt out: `optOutTracking` deletes unsent events and the stored user, so doing it
/// every launch would wipe a user who agreed. Create Mixpanel with `optOutTrackingByDefault: true`
/// instead. `setEnabled(true)` opts in when the user agrees, and Mixpanel remembers it.
///
/// Opting out on iOS also deletes the identified user's People profile in Mixpanel. That is
/// Mixpanel's own behaviour.
///
/// To keep the user id away from Mixpanel, register the provider without `identity`.
public struct MixpanelAnalyticsService: AnalyticsLifecycleService, IdentifiableUserService,
    ConsentService
{
    private let sdk: any MixpanelSDK

    public init(mixpanel: MixpanelInstance) {
        self.init(sdk: LiveMixpanelSDK(instance: mixpanel))
    }

    init(sdk: any MixpanelSDK) {
        self.sdk = sdk
    }

    /// Mixpanel is ready once `Mixpanel.initialize` has returned, so there is nothing to do.
    public func start() {}

    public func flush() {
        sdk.flush()
    }

    /// Opting out flushes first, so events sent before it still arrive. Mixpanel runs both on its
    /// own queue, in this order.
    public func setEnabled(_ enabled: Bool) {
        if enabled {
            sdk.optInTracking()
        } else {
            sdk.flush()
            sdk.optOutTracking()
        }
    }

    public func identify(_ identity: Identity) {
        sdk.identify(distinctId: identity.userId)
    }

    public func reset() {
        sdk.reset()
    }
}
