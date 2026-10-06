import HeraldCore
import Mixpanel

/// Mixpanel takes text, numbers and booleans as themselves, so every value keeps its type.
func mixpanelValue(_ value: AnalyticsValue) -> MixpanelType {
    switch value {
    case .string(let text):
        return text
    case .int(let number):
        return number
    case .double(let number):
        return number
    case .bool(let flag):
        return flag
    }
}

func mixpanelProperties(_ parameters: [String: AnalyticsValue]) -> Properties {
    var properties: Properties = [:]
    for (key, value) in parameters {
        properties[key] = mixpanelValue(value)
    }
    return properties
}

/// Why this module refused an event: it says what to change.
struct MixpanelRefusal: Error, CustomStringConvertible {
    let description: String
}
