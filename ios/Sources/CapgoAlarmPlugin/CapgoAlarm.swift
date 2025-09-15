import Foundation

@objc public class CapgoAlarm: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
}
