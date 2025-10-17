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

    static func createAlarm(hour: Int, minute: Int, label: String?, completion: @escaping (Bool, String?) -> Void) {
        #if canImport(AlarmKit)
        if #available(iOS 26.0, *) {
            guard (0..<24).contains(hour), (0..<60).contains(minute) else {
                completion(false, "Invalid time components for alarm.")
                return
            }

            Task {
                do {
                    guard let triggerDate = nextTriggerDate(hour: hour, minute: minute) else {
                        completion(false, "Unable to compute next trigger date.")
                        return
                    }
                    let displayLabel = sanitizedLabel(label)
                    let configuration = try alarmConfiguration(triggerDate: triggerDate, label: displayLabel)

                    _ = try await AlarmManager.shared.schedule(id: UUID(), configuration: configuration)

                    let formatter = DateFormatter()
                    formatter.dateStyle = .none
                    formatter.timeStyle = .short
                    formatter.locale = Locale.current
                    formatter.timeZone = Calendar.current.timeZone

                    let message = "Alarm scheduled for \(formatter.string(from: triggerDate))."
                    completion(true, message)
                } catch {
                    completion(false, "Failed to schedule alarm: \(error.localizedDescription)")
                }
            }
            return
        }
        #endif
        completion(false, "AlarmKit not available on this device/SDK")
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
}

#if canImport(AlarmKit)
@available(iOS 26.0, *)
private extension AlarmKitBridge {
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
