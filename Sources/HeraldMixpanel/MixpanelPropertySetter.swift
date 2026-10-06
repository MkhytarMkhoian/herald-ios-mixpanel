/// One call to Mixpanel for one property. A factory builds it.
public protocol MixpanelPropertySetter {
    func set() throws
}
