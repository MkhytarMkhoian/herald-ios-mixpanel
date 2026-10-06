# Herald for Mixpanel

Sends [Herald](https://github.com/MkhytarMkhoian/herald-ios) events and properties to Mixpanel,
over [`mixpanel-swift`](https://github.com/mixpanel/mixpanel-swift).

## Install

In Xcode, File → Add Package Dependencies, and add both packages:

- `https://github.com/MkhytarMkhoian/herald-ios`, for `HeraldCore`;
- `https://github.com/MkhytarMkhoian/herald-ios-mixpanel`, for `HeraldMixpanel`.

It works with `mixpanel-swift` 6, and needs iOS 15 or newer.

## Set up

Create Mixpanel as usual, then hand the instance to Herald's factories and service:

```swift
import HeraldCore
import HeraldMixpanel
import Mixpanel

let mixpanel = Mixpanel.initialize(token: "<token>", trackAutomaticEvents: false)

let tracker = MixpanelAnalyticsTrackerService(
    eventTrackerFactory: CompositeMixpanelEventTrackerFactory([
        ScreenViewMixpanelEventTrackerFactory(mixpanel: mixpanel),
        GenericMixpanelEventTrackerFactory(mixpanel: mixpanel),
    ]),
    propertySetterFactory: CompositeMixpanelPropertySetterFactory([
        UserPropertyMixpanelPropertySetterFactory(mixpanel: mixpanel),  // the People profile
        GenericMixpanelPropertySetterFactory(mixpanel: mixpanel),  // super properties
    ])
)
let service = MixpanelAnalyticsService(mixpanel: mixpanel)

let provider = HeraldProvider(
    name: "mixpanel",
    events: tracker,
    properties: tracker,
    identity: service,
    lifecycle: service,
    consent: service
)
```

| Herald | Mixpanel |
| --- | --- |
| an event | `track(event:properties:)`, with each value as its own type |
| a `ScreenViewEvent` | `track(event: "screen_view")`, with the event's name as `screen_name` |
| a `UserProperty` | `people.set(property:to:)`: the person's profile |
| any other property | `registerSuperProperties`: sent with every later event |
| `identify` / `reset` | `identify(distinctId:)` / `reset()` |
| `flush` | `flush()` |
| `setEnabled(true)` / `setEnabled(false)` | `optInTracking()` / `flush()` then `optOutTracking()` |

A screen view with its own `screen_name` parameter is refused and sent to Herald's error reporter,
because it would replace the screen's name.

**Consent.** Herald never opts out on start, because `optOutTracking` deletes unsent events and
the stored user. If a fresh install must send nothing until the user agrees, create Mixpanel with
`optOutTrackingByDefault: true`; `setEnabled(true)` then opts in, and Mixpanel remembers it. On
iOS, opting out also deletes the identified user's People profile in Mixpanel.

## Documentation

The [Herald website](https://mkhytarmkhoian.github.io/herald-docs/) has the guides.

## License

Apache License 2.0. See [LICENSE](LICENSE).
