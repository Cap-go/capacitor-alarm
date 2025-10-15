import Foundation

#if canImport(AlarmKit)
import AlarmKit
#endif

class AlarmKitBridge {
    static func isAvailable() -> Bool {
        #if canImport(AlarmKit)
        if #available(iOS 26.0, *) { return true } else { return false }
        #else
        return false
        #endif
    }

    static func requestAuthorization(completion: @escaping (Bool, String?) -> Void) {
        #if canImport(AlarmKit)
        if #available(iOS 26.0, *) {
            Task {
                do {
                    // Acquire the AlarmKit manager; many Apple frameworks use a shared singleton.
                    let alarmManager = AlarmManager.shared
                    let state = try await alarmManager.requestAuthorization()
                    completion(state == .authorized, nil)
                } catch {
                    completion(false, "Authorization error: \(error.localizedDescription)")
                }
            }
            return
        }
        #endif
        completion(false, "AlarmKit not available on this device/SDK")
    }

    static func createAlarm(hour: Int, minute: Int, label: String?, completion: @escaping (Bool, String?) -> Void) {
        #if canImport(AlarmKit)
        if #available(iOS 26.0, *) {
            // TODO: Replace with real AlarmKit calls.
            // We intentionally avoid guessing API surface to prevent compilation/runtime issues.
            completion(false, "AlarmKit integrated but no concrete API wired. Provide exact AlarmKit API usage.")
            return
        }
        #endif
        completion(false, "AlarmKit not available on this device/SDK")
    }

    static func openAlarms(completion: @escaping (Bool, String?) -> Void) {
        #if canImport(AlarmKit)
        if #available(iOS 26.0, *) {
            // TODO: Replace with real AlarmKit calls.
            completion(false, "AlarmKit integrated but no concrete API wired. Provide exact AlarmKit API usage.")
            return
        }
        #endif
        completion(false, "AlarmKit not available on this device/SDK")
    }
}
