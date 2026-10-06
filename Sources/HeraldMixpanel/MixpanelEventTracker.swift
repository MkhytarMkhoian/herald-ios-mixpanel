/// One call to Mixpanel for one event. A factory builds it.
public protocol MixpanelEventTracker {
    func track() throws
}
