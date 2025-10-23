import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(CapgoAlarmPlugin)
public class CapgoAlarmPlugin: CAPPlugin, CAPBridgedPlugin {
    private let PLUGIN_VERSION: String = "7.3.4"
    public let identifier = "CapgoAlarmPlugin"
    public let jsName = "CapgoAlarm"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "createAlarm", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "openAlarms", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getOSInfo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "requestPermissions", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getPluginVersion", returnType: CAPPluginReturnPromise)
    ]

    @objc func createAlarm(_ call: CAPPluginCall) {
        let hour = call.getInt("hour") ?? -1
        let minute = call.getInt("minute") ?? -1
        if hour < 0 || minute < 0 { call.reject("hour and minute are required"); return }
        let label = call.getString("label")

        AlarmKitBridge.createAlarm(hour: hour, minute: minute, label: label) { success, message in
            call.resolve(["success": success, "message": message ?? NSNull()])
        }
    }

    @objc func openAlarms(_ call: CAPPluginCall) {
        AlarmKitBridge.openAlarms { success, message in
            call.resolve(["success": success, "message": message ?? NSNull()])
        }
    }

    @objc func getOSInfo(_ call: CAPPluginCall) {
        let version = UIDevice.current.systemVersion
        let supportsNative = AlarmKitBridge.isAvailable()
        call.resolve([
            "platform": "ios",
            "version": version,
            "supportsNativeAlarms": supportsNative,
            "supportsScheduledNotifications": true
        ])
    }

    // Capacitor permission lifecycle
    override public func checkPermissions(_ call: CAPPluginCall) {
        // No explicit runtime permission needed for AlarmKit; always granted when available
        call.resolve(["granted": true])
    }

    override public func requestPermissions(_ call: CAPPluginCall) {
        // Request AlarmKit authorization when available
        if !AlarmKitBridge.isAvailable() {
            call.resolve(["granted": false])
            return
        }
        AlarmKitBridge.requestAuthorization { granted, message in
            var result: [String: Any] = ["granted": granted]
            if let message = message { result["message"] = message }
            call.resolve(result)
        }
    }

    // No data conversion helpers needed for native-only operations

    @objc func getPluginVersion(_ call: CAPPluginCall) {
        call.resolve(["version": self.PLUGIN_VERSION])
    }

}
