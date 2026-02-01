import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(CapgoAlarmPlugin)
public class CapgoAlarmPlugin: CAPPlugin, CAPBridgedPlugin {
    private let pluginVersion: String = "8.0.6"
    public let identifier = "CapgoAlarmPlugin"
    public let jsName = "CapgoAlarm"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "createAlarm", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "openAlarms", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getOSInfo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "checkPermissions", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "requestPermissions", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getPluginVersion", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getAlarms", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "cancelAlarm", returnType: CAPPluginReturnPromise)
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
        guard AlarmKitBridge.isAvailable() else {
            call.resolve([
                "granted": false,
                "details": ["alarmKit": false],
                "message": "AlarmKit not available on this device/SDK",
            ])
            return
        }

        AlarmKitBridge.currentAuthorizationStatus { granted, statusDescription in
            var result: [String: Any] = [
                "granted": granted,
                "details": ["alarmKit": granted],
            ]
            if !granted, let statusDescription = statusDescription {
                result["message"] = "AlarmKit authorization status: \(statusDescription)"
            }
            call.resolve(result)
        }
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
        call.resolve(["version": self.pluginVersion])
    }

    @objc func getAlarms(_ call: CAPPluginCall) {
        AlarmKitBridge.getAlarms { alarms, error in
            if let error = error {
                // Return empty array with error message for consistency
                call.resolve(["alarms": [], "message": error])
            } else {
                call.resolve(["alarms": alarms])
            }
        }
    }

    @objc func cancelAlarm(_ call: CAPPluginCall) {
        guard let id = call.getString("id") else {
            call.reject("Missing alarm id")
            return
        }
        AlarmKitBridge.cancelAlarm(id: id) { success, message in
            call.resolve(["success": success, "message": message ?? NSNull()])
        }
    }

}
