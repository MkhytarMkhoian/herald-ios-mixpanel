import HeraldCore
import Testing

@testable import HeraldMixpanel

@Test func parametersKeepTheirTypes() {
    let mixpanel = RecordingMixpanelSDK()
    let event = TestEvent(
        name: "checkout_started",
        parameters: [
            "plan": .string("pro"), "seats": .int(3), "price": .double(9.99), "trial": .bool(false),
        ])

    GenericMixpanelEventTracker(event: event, sdk: mixpanel).track()

    #expect(
        mixpanel.calls == [
            "track checkout_started plan=String(pro) price=Double(9.99) seats=Int(3) "
                + "trial=Bool(false)"
        ])
}

@Suite struct Trackers {
    let mixpanel = RecordingMixpanelSDK()

    @Test func theGenericTrackerSendsTheEventUnderItsOwnName() {
        GenericMixpanelEventTracker(event: TestEvent(name: "cart_viewed"), sdk: mixpanel)
            .track()

        #expect(mixpanel.calls == ["track cart_viewed"])
    }

    @Test func aScreenViewIsScreenViewWithItsNameAsScreenName() throws {
        let screen = TestScreenView(name: "checkout", parameters: ["source": .string("cart")])

        try ScreenViewMixpanelEventTracker(event: screen, sdk: mixpanel).track()

        #expect(
            mixpanel.calls == ["track screen_view screen_name=String(checkout) source=String(cart)"]
        )
    }

    @Test func aScreenViewWithItsOwnScreenNameParameterIsRefusedAndNothingIsSent() {
        let screen = TestScreenView(name: "checkout", parameters: ["screen_name": .string("other")])

        #expect {
            try ScreenViewMixpanelEventTracker(event: screen, sdk: mixpanel).track()
        } throws: { error in
            "\(error)".contains("can't have a 'screen_name' parameter")
        }
        #expect(mixpanel.calls.isEmpty)
    }

    @Test func aPropertyBecomesASuperPropertyWithItsType() {
        GenericMixpanelPropertySetter(
            property: TestProperty(name: "seats", value: .int(3)), sdk: mixpanel
        ).set()

        #expect(mixpanel.calls == ["registerSuperProperties seats=Int(3)"])
    }

    @Test func aUserPropertyIsWrittenToThePeopleProfile() {
        UserPropertyMixpanelPropertySetter(
            property: TestUserProperty(name: "plan", value: .string("pro")), sdk: mixpanel
        ).set()

        #expect(mixpanel.calls == ["people.set plan=String(pro)"])
    }
}

@Suite struct Factories {
    let mixpanel = RecordingMixpanelSDK()

    private var tracker: MixpanelAnalyticsTrackerService {
        MixpanelAnalyticsTrackerService(
            eventTrackerFactory: CompositeMixpanelEventTrackerFactory([
                ScreenViewMixpanelEventTrackerFactory(sdk: mixpanel),
                GenericMixpanelEventTrackerFactory(sdk: mixpanel),
            ]),
            propertySetterFactory: CompositeMixpanelPropertySetterFactory([
                UserPropertyMixpanelPropertySetterFactory(sdk: mixpanel),
                GenericMixpanelPropertySetterFactory(sdk: mixpanel),
            ])
        )
    }

    @Test func aUserPropertyReachesTheProfileAndAnOrdinaryOneTheSuperProperties() {
        let herald = Herald(providers: [HeraldProvider(name: "mixpanel", properties: tracker)])

        herald.set(TestUserProperty(name: "plan", value: .string("pro")))
        herald.set(TestProperty(name: "theme", value: .string("dark")))

        #expect(
            mixpanel.calls == [
                "people.set plan=String(pro)", "registerSuperProperties theme=String(dark)",
            ])
    }

    @Test func screenViewsAndOtherEventsTakeTheirOwnPaths() {
        let herald = Herald(providers: [HeraldProvider(name: "mixpanel", events: tracker)])

        herald.track(TestScreenView(name: "home"))
        herald.track(TestEvent(name: "cart_viewed"))

        #expect(
            mixpanel.calls == ["track screen_view screen_name=String(home)", "track cart_viewed"])
    }

    @Test func theUserPropertyFactoryDeclinesAnOrdinaryProperty() throws {
        let factory = UserPropertyMixpanelPropertySetterFactory(sdk: mixpanel)

        #expect(
            try factory.create(TestProperty(name: "theme", value: .string("dark"))).handlers()
                .isEmpty)
    }

    @Test func aChainEndingInRequireMappedReportsAnUnclaimedEventThroughHerald() throws {
        let failures = ReportedFailures()
        let tracker = MixpanelAnalyticsTrackerService(
            eventTrackerFactory: CompositeMixpanelEventTrackerFactory([
                ScreenViewMixpanelEventTrackerFactory(sdk: mixpanel),
                RequireMappedMixpanelEventTrackerFactory(),
            ]),
            propertySetterFactory: RequireMappedMixpanelPropertySetterFactory()
        )
        let herald = Herald(
            providers: [HeraldProvider(name: "mixpanel", events: tracker, properties: tracker)],
            errorReporter: { failure in failures.append(failure) }
        )

        herald.track(TestEvent(name: "checkout_started"))
        herald.set(TestProperty(name: "plan", value: .string("pro")))

        #expect(mixpanel.calls.isEmpty)
        let failure = try #require(failures.all.first)
        #expect(failure.operation == .track(eventName: "checkout_started"))
        #expect(failure.error is UnhandledEventError)
        #expect(failures.all.last?.error is UnhandledPropertyError)
    }

    @Test func aRefusedScreenViewIsReportedThroughHerald() throws {
        let failures = ReportedFailures()
        let herald = Herald(
            providers: [HeraldProvider(name: "mixpanel", events: tracker)],
            errorReporter: { failure in failures.append(failure) }
        )

        herald.track(TestScreenView(name: "home", parameters: ["screen_name": .string("x")]))

        let failure = try #require(failures.all.first)
        #expect("\(failure)".hasPrefix("mixpanel failed on Track(home): Screen view 'home'"))
        #expect(mixpanel.calls.isEmpty)
    }
}

@Suite struct Service {
    let mixpanel = RecordingMixpanelSDK()

    @Test func startDoesNotTouchMixpanelSoItNeverOptsOut() {
        MixpanelAnalyticsService(sdk: mixpanel).start()

        #expect(mixpanel.calls.isEmpty)
    }

    @Test func revokingConsentFlushesBeforeOptingOutAndGrantingOptsIn() {
        let service = MixpanelAnalyticsService(sdk: mixpanel)

        service.setEnabled(false)
        service.setEnabled(true)

        #expect(mixpanel.calls == ["flush", "optOutTracking", "optInTracking"])
    }

    @Test func flushSendsWhatMixpanelHasBuffered() {
        MixpanelAnalyticsService(sdk: mixpanel).flush()

        #expect(mixpanel.calls == ["flush"])
    }

    @Test func identifyAndResetReachMixpanel() {
        let service = MixpanelAnalyticsService(sdk: mixpanel)

        service.identify(Identity(userId: "user-1"))
        service.reset()

        #expect(mixpanel.calls == ["identify user-1", "reset"])
    }
}
