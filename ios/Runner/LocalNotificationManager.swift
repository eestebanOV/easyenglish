import Foundation
import UserNotifications

public class LocalNotificationManager: NSObject {
    public static let shared = LocalNotificationManager()

    private let appGroupId = "group.com.easyenglish.app"

    private let keyActive = "live_activity_is_active"
    private let keyWordEn = "live_activity_word_en"
    private let keyWordEs = "live_activity_word_es"
    private let keyPronunciation = "live_activity_pronunciation"
    private let keyType = "live_activity_type"
    private let keyCategory = "live_activity_category"
    private let keyVerbPresent = "live_activity_verb_present"
    private let keyVerbPast = "live_activity_verb_past"
    private let keyVerbParticiple = "live_activity_verb_participle"
    private let keyExamplesJson = "live_activity_examples_json"
    private let keyStartHour = "live_activity_start_hour"
    private let keyEndHour = "live_activity_end_hour"
    private let keyIntervalMinutes = "live_activity_interval_minutes"
    private let keyCurrentExampleIndex = "live_activity_current_example_index"
    private let keyLastSessionDate = "live_activity_last_session_date"
    private let keyCardId = "live_activity_card_id"

    private let notificationPrefixId = "easyenglish_daily_"

    private var defaults: UserDefaults {
        return UserDefaults(suiteName: appGroupId) ?? UserDefaults.standard
    }

    private func saveToDefaults<T>(_ value: T?, forKey key: String) {
        if let val = value {
            UserDefaults(suiteName: appGroupId)?.set(val, forKey: key)
            UserDefaults.standard.set(val, forKey: key)
        } else {
            UserDefaults(suiteName: appGroupId)?.removeObject(forKey: key)
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults(suiteName: appGroupId)?.synchronize()
        UserDefaults.standard.synchronize()
    }

    private func getString(forKey key: String) -> String? {
        if let val = UserDefaults(suiteName: appGroupId)?.string(forKey: key), !val.isEmpty {
            return val
        }
        return UserDefaults.standard.string(forKey: key)
    }

    private func getBool(forKey key: String) -> Bool {
        if let groupDefs = UserDefaults(suiteName: appGroupId), groupDefs.object(forKey: key) != nil {
            return groupDefs.bool(forKey: key)
        }
        return UserDefaults.standard.bool(forKey: key)
    }

    private func getInt(forKey key: String, defaultValue: Int = 0) -> Int {
        if let groupDefs = UserDefaults(suiteName: appGroupId), groupDefs.object(forKey: key) != nil {
            return groupDefs.integer(forKey: key)
        }
        let std = UserDefaults.standard.integer(forKey: key)
        return std != 0 ? std : defaultValue
    }

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    public func requestAuthorizationIfNeeded(completion: ((_ granted: Bool) -> Void)? = nil) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    DispatchQueue.main.async { completion?(granted) }
                }
            } else {
                let granted = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
                DispatchQueue.main.async { completion?(granted) }
            }
        }
    }

    // MARK: - Public API for Flutter / Native

    /// Start a full day of local notifications with rotating examples for the selected word.
    public func startDayLearning(
        learningItem: String,
        type: String,
        translation: String,
        phonetic: String,
        examples: [String],
        verbPresent: String? = nil,
        verbPast: String? = nil,
        verbParticiple: String? = nil,
        categoryName: String = "English Every Day",
        startHour: Int = 8,
        endHour: Int = 22,
        intervalMinutes: Int = 30,
        cardId: String = ""
    ) -> [String: Any] {
        guard !learningItem.isEmpty, !examples.isEmpty else {
            print("[LocalNotifications] Error: Invalid learning item or examples")
            return ["success": false, "error": "Invalid learning item or examples"]
        }

        let jsonExamples = (try? JSONEncoder().encode(examples)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        saveToDefaults(true, forKey: keyActive)
        saveToDefaults(learningItem, forKey: keyWordEn)
        saveToDefaults(translation, forKey: keyWordEs)
        saveToDefaults(phonetic, forKey: keyPronunciation)
        saveToDefaults(type, forKey: keyType)
        saveToDefaults(categoryName, forKey: keyCategory)
        saveToDefaults(verbPresent ?? "", forKey: keyVerbPresent)
        saveToDefaults(verbPast ?? "", forKey: keyVerbPast)
        saveToDefaults(verbParticiple ?? "", forKey: keyVerbParticiple)
        saveToDefaults(jsonExamples, forKey: keyExamplesJson)
        saveToDefaults(startHour, forKey: keyStartHour)
        saveToDefaults(endHour, forKey: keyEndHour)
        saveToDefaults(intervalMinutes, forKey: keyIntervalMinutes)
        saveToDefaults(0, forKey: keyCurrentExampleIndex)
        saveToDefaults(Date().timeIntervalSince1970, forKey: keyLastSessionDate)
        saveToDefaults(cardId, forKey: keyCardId)

        var scheduledCount = 0
        let group = DispatchGroup()
        group.enter()

        requestAuthorizationIfNeeded { granted in
            defer { group.leave() }
            guard granted else {
                print("[LocalNotifications] Authorization denied by user")
                return
            }

            scheduledCount = self.scheduleDayNotifications(
                learningItem: learningItem,
                translation: translation,
                phonetic: phonetic,
                type: type,
                examples: examples,
                startHour: startHour,
                endHour: endHour,
                intervalMinutes: intervalMinutes
            )
        }

        _ = group.wait(timeout: .now() + 5.0)

        print("[LocalNotifications] startDayLearning finished. Scheduled ~\(scheduledCount) notifications for '\(learningItem)' every \(intervalMinutes) min.")

        return [
            "success": true,
            "learningItem": learningItem,
            "totalExamples": examples.count,
            "intervalMinutes": intervalMinutes,
            "startHour": startHour,
            "endHour": endHour
        ]
    }

    /// Schedules all notifications for the current day. Returns the number of scheduled notifications.
    @discardableResult
    private func scheduleDayNotifications(
        learningItem: String,
        translation: String,
        phonetic: String,
        type: String,
        examples: [String],
        startHour: Int,
        endHour: Int,
        intervalMinutes: Int
    ) -> Int {
        let center = UNUserNotificationCenter.current()

        let pendingIdsToRemove = center.getPendingNotificationRequests { requests in
            let ids = requests
                .map { $0.identifier }
                .filter { $0.hasPrefix(self.notificationPrefixId) }
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }

        let calendar = Calendar.current
        let now = Date()
        let safeInterval = max(5, intervalMinutes)

        var scheduledCount = 0
        var exampleCounter = 0

        let totalMinutesInWindow = ((endHour - startHour) * 60)
        let slots = totalMinutesInWindow / safeInterval

        for slot in 0...slots {
            let offsetMinutes = slot * safeInterval
            let hourOffset = offsetMinutes / 60
            let minuteOffset = offsetMinutes % 60

            let hour = startHour + hourOffset
            let minute = minuteOffset

            if hour > endHour || (hour == endHour && minute > 0) { break }

            let exampleText = examples[exampleCounter % examples.count]
            exampleCounter += 1

            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute

            let identifier = "\(notificationPrefixId)\(hour)_\(minute)_\(slot)"

            let content = UNMutableNotificationContent()
            content.title = "📚 \(learningItem)"
            let subtitleBase = translation.isEmpty ? "" : "— \(translation)"
            let pronunciationPart = phonetic.isEmpty ? "" : "  \(phonetic)"
            content.subtitle = "\(subtitleBase)\(pronunciationPart)"
            content.body = "Ejemplo \(exampleCounter)/\(examples.count): \"\(exampleText)\""
            content.sound = .default
            content.userInfo = [
                "action": "daily_learning_notification",
                "learningItem": learningItem,
                "translation": translation,
                "example": exampleText,
                "exampleIndex": exampleCounter - 1,
                "totalExamples": examples.count
            ]
            content.threadIdentifier = "easyenglish_daily_learning"
            content.categoryIdentifier = "LEARNING_CATEGORY"

            // Only schedule slots that are in the future from 'now' today (avoid immediate past duplicates)
            if let scheduledDate = calendar.nextDate(
                after: calendar.startOfDay(for: now),
                matching: dateComponents,
                matchingPolicy: .nextTime
            ) {
                if scheduledDate <= now {
                    continue
                }

                let triggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: scheduledDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                center.add(request) { err in
                    if let err = err {
                        print("[LocalNotifications] Error scheduling \(identifier): \(err.localizedDescription)")
                    }
                }
                scheduledCount += 1
            }
        }

        saveToDefaults(0, forKey: keyCurrentExampleIndex)
        return scheduledCount
    }

    /// Trigger an immediate local notification now (for testing / manual session).
    public func triggerImmediateNotification(exampleIndex: Int? = nil) -> [String: Any] {
        guard getBool(forKey: keyActive) else {
            return ["success": false, "error": "Daily learning is not active"]
        }

        let learningItem = getString(forKey: keyWordEn) ?? ""
        let translation = getString(forKey: keyWordEs) ?? ""
        let phonetic = getString(forKey: keyPronunciation) ?? ""
        let type = getString(forKey: keyType) ?? ""

        var examples: [String] = []
        if let jsonStr = getString(forKey: keyExamplesJson),
           let data = jsonStr.data(using: .utf8),
           let list = try? JSONDecoder().decode([String].self, from: data),
           !list.isEmpty {
            examples = list
        } else {
            return ["success": false, "error": "No examples saved"]
        }

        let savedIdx = getInt(forKey: keyCurrentExampleIndex, defaultValue: 0)
        let targetIndex = (exampleIndex ?? savedIdx) % examples.count
        let exampleText = examples[targetIndex]

        let content = UNMutableNotificationContent()
        content.title = "📚 \(learningItem)"
        let subtitleBase = translation.isEmpty ? "" : "— \(translation)"
        let pronunciationPart = phonetic.isEmpty ? "" : "  \(phonetic)"
        content.subtitle = "\(subtitleBase)\(pronunciationPart)"
        content.body = "Ejemplo \(targetIndex + 1)/\(examples.count): \"\(exampleText)\""
        content.sound = .default
        content.userInfo = [
            "action": "manual_learning_notification",
            "learningItem": learningItem,
            "example": exampleText,
            "exampleIndex": targetIndex,
            "totalExamples": examples.count
        ]
        content.threadIdentifier = "easyenglish_daily_learning"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "\(notificationPrefixId)immediate_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { err in
            if let err = err {
                print("[LocalNotifications] Immediate error: \(err.localizedDescription)")
            }
        }

        let nextIndex = (targetIndex + 1) % examples.count
        saveToDefaults(nextIndex, forKey: keyCurrentExampleIndex)

        return ["success": true, "example": exampleText, "index": targetIndex]
    }

    /// Cancels all scheduled local notifications and clears day-learning state.
    public func stopDayLearning() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let ids = requests
                .map { $0.identifier }
                .filter { $0.hasPrefix(self.notificationPrefixId) }
            center.removePendingNotificationRequests(withIdentifiers: ids)
            center.removeDeliveredNotifications(withIdentifiers: ids)
        }

        let defs = defaults
        defs.set(false, forKey: keyActive)
        defs.set("", forKey: keyWordEn)
        defs.set("", forKey: keyWordEs)
        defs.set("", forKey: keyPronunciation)
        defs.set("[]", forKey: keyExamplesJson)
        defs.set("", forKey: keyCardId)
        defs.synchronize()
    }

    /// Retrieves current state for Flutter UI.
    public func getActiveState() -> [String: Any] {
        let defs = defaults
        let isActive = defs.bool(forKey: keyActive)
        let wordEn = defs.string(forKey: keyWordEn) ?? ""
        let wordEs = defs.string(forKey: keyWordEs) ?? ""
        let phonetic = defs.string(forKey: keyPronunciation) ?? ""
        let type = defs.string(forKey: keyType) ?? "PHRASE"
        let category = defs.string(forKey: keyCategory) ?? ""
        let startHour = defs.integer(forKey: keyStartHour)
        let endHour = defs.integer(forKey: keyEndHour)
        let intervalMins = defs.integer(forKey: keyIntervalMinutes)
        let currentIdx = defs.integer(forKey: keyCurrentExampleIndex)
        let cardId = defs.string(forKey: keyCardId) ?? ""

        var examples: [String] = []
        if let jsonStr = defs.string(forKey: keyExamplesJson),
           let data = jsonStr.data(using: .utf8),
           let list = try? JSONDecoder().decode([String].self, from: data) {
            examples = list
        }

        var pendingCount = 0
        let semaphore = DispatchSemaphore(value: 0)
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            pendingCount = requests.filter { $0.identifier.hasPrefix(self.notificationPrefixId) }.count
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: .now() + 1.0)

        return [
            "isActive": isActive,
            "isCurrentlyLive": false,
            "wordEn": wordEn,
            "wordEs": wordEs,
            "phonetic": phonetic,
            "type": type,
            "category": category,
            "examples": examples,
            "startHour": startHour,
            "endHour": endHour,
            "intervalMinutes": intervalMins,
            "durationMinutes": 0,
            "currentExampleIndex": currentIdx,
            "cardId": cardId,
            "pendingNotifications": pendingCount
        ]
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension LocalNotificationManager: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound, .badge])
    }

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}
