import Foundation
#if canImport(UIKit)
import UIKit
#endif

#if canImport(AlarmKit)
import AlarmKit
#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 26.0, *)
private struct AlarmBridgeMetadata: AlarmMetadata {
    let label: String
}
#endif

class AlarmKitBridge {
    // MARK: - UserDefaults Storage for Alarm Metadata

    private static let storageKey = "CapgoAlarm.alarmMetadata"
    private static let metadataQueue = DispatchQueue(label: "CapgoAlarm.alarmMetadata.queue")

    private static func loadStoredMetadata() -> [String: [String: Any]] {
        UserDefaults.standard.dictionary(forKey: storageKey) as? [String: [String: Any]] ?? [:]
    }

    private static func saveStoredMetadata(_ metadata: [String: [String: Any]]) {
        UserDefaults.standard.set(metadata, forKey: storageKey)
    }

    private static func storeAlarmMetadata(id: String, hour: Int, minute: Int, label: String?) {
        metadataQueue.sync {
            var metadata = loadStoredMetadata()
            var entry: [String: Any] = [
                "hour": hour,
                "minute": minute
            ]
            if let label = label {
                entry["label"] = label
            }
            metadata[id] = entry
            saveStoredMetadata(metadata)
        }
    }

    private static func removeAlarmMetadata(id: String) {
        metadataQueue.sync {
            var metadata = loadStoredMetadata()
            metadata.removeValue(forKey: id)
            saveStoredMetadata(metadata)
        }
    }

    private static func getAlarmMetadata(id: String) -> (hour: Int, minute: Int, label: String?)? {
        metadataQueue.sync {
            let metadata = loadStoredMetadata()
            guard let data = metadata[id],
                  let hour = data["hour"] as? Int,
                  let minute = data["minute"] as? Int else {
                return nil
            }
            let label = data["label"] as? String
            return (hour, minute, label)
        }
    }

    private static func pruneOrphanedMetadata(validIds: Set<String>) {
        metadataQueue.sync {
            var metadata = loadStoredMetadata()
            let storedIds = Set(metadata.keys)
            let orphanedIds = storedIds.subtracting(validIds)
            for id in orphanedIds {
                metadata.removeValue(forKey: id)
            }
            if !orphanedIds.isEmpty {
                saveStoredMetadata(metadata)
            }
        }
    }

    // MARK: - Public API

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

    static func currentAuthorizationStatus(completion: @escaping (Bool, String?) -> Void) {
        #if canImport(AlarmKit)
        if #available(iOS 26.0, *) {
            let status = AlarmManager.shared.authorizationState
            completion(status == .authorized, String(describing: status))
            return
        }
        #endif
        completion(false, "AlarmKit not available on this device/SDK")
    }

    static func createAlarm(hour: Int, minute: Int, label: String?, completion: @escaping (Bool, String?, String?) -> Void) {
        #if canImport(AlarmKit)
        if #available(iOS 26.0, *) {
            guard (0..<24).contains(hour), (0..<60).contains(minute) else {
                completion(false, "Invalid time components for alarm.", nil)
                return
            }

            Task {
                do {
                    guard let triggerDate = nextTriggerDate(hour: hour, minute: minute) else {
                        completion(false, "Unable to compute next trigger date.", nil)
                        return
                    }
                    let displayLabel = sanitizedLabel(label)
                    let configuration = try alarmConfiguration(triggerDate: triggerDate, label: displayLabel)

                    // Generate UUID upfront so we can return it and store metadata
                    let alarmId = UUID()
                    _ = try await AlarmManager.shared.schedule(id: alarmId, configuration: configuration)

                    // Store metadata for later retrieval (use displayLabel so stored title matches system)
                    storeAlarmMetadata(id: alarmId.uuidString, hour: hour, minute: minute, label: displayLabel)

                    let formatter = DateFormatter()
                    formatter.dateStyle = .none
                    formatter.timeStyle = .short
                    formatter.locale = Locale.current
                    formatter.timeZone = Calendar.current.timeZone

                    let message = "Alarm scheduled for \(formatter.string(from: triggerDate))."
                    completion(true, message, alarmId.uuidString)
                } catch {
                    completion(false, "Failed to schedule alarm: \(error.localizedDescription)", nil)
                }
            }
            return
        }
        #endif
        completion(false, "AlarmKit not available on this device/SDK", nil)
    }

    static func openAlarms(completion: @escaping (Bool, String?) -> Void) {
        #if canImport(UIKit)
        DispatchQueue.main.async {
            let candidates = AlarmKitBridge.clockURLCandidates()
            attemptOpenClock(urls: candidates, index: 0, completion: completion)
        }
        #else
        completion(false, "Clock UI cannot be opened on this platform.")
        #endif
    }

    static func getAlarms(completion: @escaping ([[String: Any]], String?) -> Void) {
        #if canImport(AlarmKit)
        if #available(iOS 26.0, *) {
            Task {
                do {
                    let alarmManager = AlarmManager.shared
                    let alarms = try alarmManager.alarms

                    // Collect valid alarm IDs and prune orphaned metadata
                    let validIds = Set(alarms.map { $0.id.uuidString })
                    pruneOrphanedMetadata(validIds: validIds)

                    var alarmsList: [[String: Any]] = []
                    for alarm in alarms {
                        if let alarmDict = convertAlarmToDict(alarm: alarm) {
                            alarmsList.append(alarmDict)
                        }
                    }

                    completion(alarmsList, nil)
                } catch {
                    completion([], "Failed to retrieve alarms: \(error.localizedDescription)")
                }
            }
            return
        }
        #endif
        // Return empty list for consistency with Android/Web when not supported
        completion([], nil)
    }

    static func cancelAlarm(id: String, completion: @escaping (Bool, String?) -> Void) {
        #if canImport(AlarmKit)
        if #available(iOS 26.0, *) {
            guard let uuid = UUID(uuidString: id) else {
                completion(false, "Invalid alarm ID format")
                return
            }
            do {
                try AlarmManager.shared.cancel(id: uuid)
                // Clean up stored metadata
                removeAlarmMetadata(id: id)
                completion(true, "Alarm cancelled")
            } catch {
                completion(false, "Failed to cancel alarm: \(error.localizedDescription)")
            }
            return
        }
        #endif
        completion(false, "AlarmKit not available on this device/SDK")
    }
}

#if canImport(AlarmKit)
@available(iOS 26.0, *)
private extension AlarmKitBridge {
    static func convertAlarmToDict(alarm: Alarm) -> [String: Any]? {
        let idString = alarm.id.uuidString
        let isEnabled = alarm.state == .scheduled || alarm.state == .countdown || alarm.state == .alerting

        var dict: [String: Any] = [
            "id": idString,
            "enabled": isEnabled
        ]

        // Look up stored metadata for hour/minute/label
        if let metadata = getAlarmMetadata(id: idString) {
            dict["hour"] = metadata.hour
            dict["minute"] = metadata.minute
            if let label = metadata.label {
                dict["label"] = label
            }
        }
        // If no stored metadata (alarm created outside this plugin), hour/minute/label are omitted

        return dict
    }
    
    static func sanitizedLabel(_ label: String?) -> String {
        let trimmed = label?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? "Alarm" : trimmed
    }

    static func nextTriggerDate(hour: Int, minute: Int) -> Date? {
        let now = Date()
        var components = Calendar.current.dateComponents([.year, .month, .day], from: now)
        components.hour = hour
        components.minute = minute
        components.second = 0

        guard let candidate = Calendar.current.date(from: components) else { return nil }
        if candidate.timeIntervalSince(now) > 1 {
            return candidate
        }
        return Calendar.current.date(byAdding: .day, value: 1, to: candidate)
    }

    static func alarmConfiguration(triggerDate: Date, label: String) throws -> AlarmManager.AlarmConfiguration<AlarmBridgeMetadata> {
        #if canImport(SwiftUI)
        let stopTitle: LocalizedStringResource = LocalizedStringResource("Stop")
        let stopButton = AlarmButton(text: stopTitle, textColor: Color.white, systemImageName: "stop.fill")

        let titleResource = LocalizedStringResource(String.LocalizationValue(label))
        let alert = AlarmPresentation.Alert(title: titleResource, stopButton: stopButton)
        let presentation = AlarmPresentation(alert: alert)

        let tintColor = Color.orange
        let metadata = AlarmBridgeMetadata(label: label)

        let attributes = AlarmAttributes<AlarmBridgeMetadata>(presentation: presentation, metadata: metadata, tintColor: tintColor)
        return AlarmManager.AlarmConfiguration<AlarmBridgeMetadata>.alarm(
            schedule: .fixed(triggerDate),
            attributes: attributes
        )
        #else
        struct MissingSwiftUI: Error {}
        throw MissingSwiftUI()
        #endif
    }

}
#endif

#if canImport(UIKit)
private extension AlarmKitBridge {
    static func clockURLCandidates() -> [URL] {
        ["clock-alarm://", "clock://", "clock-app://"].compactMap { URL(string: $0) }
    }

    static func attemptOpenClock(urls: [URL], index: Int, completion: @escaping (Bool, String?) -> Void) {
        guard index < urls.count else {
            completion(false, "Clock app not reachable on this device.")
            return
        }

        UIApplication.shared.open(urls[index], options: [:]) { success in
            if success {
                completion(true, nil)
            } else {
                attemptOpenClock(urls: urls, index: index + 1, completion: completion)
            }
        }
    }
}
#endif
