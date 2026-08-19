#if canImport(ActivityKit)
import Foundation
import ActivityKit
import UserNotifications
import BackgroundTasks

public class LiveActivityManager: NSObject {
    public static let shared = LiveActivityManager()
    
    private let appGroupId = "group.com.easyenglish.app"
    private let bgTaskIdentifier = "com.easyenglish.app.refreshLiveActivity"
    private var internalTimer: Timer?

    // Keys for UserDefaults
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
    private let keyDurationMinutes = "live_activity_duration_minutes"
    private let keyCurrentExampleIndex = "live_activity_current_example_index"
    private let keyLastSessionDate = "live_activity_last_session_date"
    private let keyCardId = "live_activity_card_id"

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
    }

    // MARK: - Public API for Flutter / Native

    /// Start a new day of Live Activities for the selected word/phrase
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
        durationMinutes: Int = 5,
        cardId: String = ""
    ) -> [String: Any] {
        guard !learningItem.isEmpty, !examples.isEmpty else {
            print("[LiveActivity] Error: Invalid learning item or examples")
            return ["success": false, "error": "Invalid learning item or examples"]
        }

        // Save Day Configuration across both AppGroup and Standard UserDefaults
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
        saveToDefaults(durationMinutes, forKey: keyDurationMinutes)
        saveToDefaults(0, forKey: keyCurrentExampleIndex)
        saveToDefaults(cardId, forKey: keyCardId)

        // Schedule all notifications & background sessions for the day
        scheduleDaySessions(
            learningItem: learningItem,
            examples: examples,
            startHour: startHour,
            endHour: endHour,
            intervalMinutes: intervalMinutes,
            durationMinutes: durationMinutes
        )

        // Start first session immediately using explicit parameters
        let started = triggerLiveActivity(
            learningItem: learningItem,
            type: type,
            translation: translation,
            phonetic: phonetic,
            examples: examples,
            exampleIndex: 0,
            verbPresent: verbPresent,
            verbPast: verbPast,
            verbParticiple: verbParticiple,
            categoryName: categoryName,
            durationMinutes: durationMinutes
        )
        
        print("[LiveActivity] startDayLearning finished. Immediate start: \(started)")

        return [
            "success": true,
            "startedImmediate": started,
            "learningItem": learningItem,
            "totalExamples": examples.count,
            "intervalMinutes": intervalMinutes,
            "durationMinutes": durationMinutes
        ]
    }

    /// Triggers a 5-minute Live Activity session with the specified or next example
    @discardableResult
    public func startSession(exampleIndex: Int? = nil) -> Bool {
        guard #available(iOS 16.1, *) else {
            print("[LiveActivity] iOS version < 16.1, Live Activities not supported")
            return false
        }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("[LiveActivity] Live Activities are disabled by user in iOS Settings")
            return false
        }
        guard getBool(forKey: keyActive) else {
            print("[LiveActivity] Daily learning is not active")
            return false
        }

        let learningItem = getString(forKey: keyWordEn) ?? ""
        guard !learningItem.isEmpty else {
            print("[LiveActivity] No learning item saved in storage")
            return false
        }

        let translation = getString(forKey: keyWordEs) ?? ""
        let phonetic = getString(forKey: keyPronunciation) ?? ""
        let type = getString(forKey: keyType) ?? "PHRASE"
        let categoryName = getString(forKey: keyCategory) ?? "English Every Day"
        let verbPresent = getString(forKey: keyVerbPresent)
        let verbPast = getString(forKey: keyVerbPast)
        let verbParticiple = getString(forKey: keyVerbParticiple)
        let durationMins = max(1, getInt(forKey: keyDurationMinutes, defaultValue: 5))

        var examples: [String] = []
        if let jsonStr = getString(forKey: keyExamplesJson),
           let data = jsonStr.data(using: .utf8),
           let list = try? JSONDecoder().decode([String].self, from: data),
           !list.isEmpty {
            examples = list
        } else {
            examples = ["Take care of yourself."]
        }

        let savedIdx = getInt(forKey: keyCurrentExampleIndex, defaultValue: 0)
        let targetIndex = (exampleIndex ?? savedIdx) % examples.count

        return triggerLiveActivity(
            learningItem: learningItem,
            type: type,
            translation: translation,
            phonetic: phonetic,
            examples: examples,
            exampleIndex: targetIndex,
            verbPresent: verbPresent,
            verbPast: verbPast,
            verbParticiple: verbParticiple,
            categoryName: categoryName,
            durationMinutes: durationMins
        )
    }

    private func triggerLiveActivity(
        learningItem: String,
        type: String,
        translation: String,
        phonetic: String,
        examples: [String],
        exampleIndex: Int,
        verbPresent: String?,
        verbPast: String?,
        verbParticiple: String?,
        categoryName: String,
        durationMinutes: Int
    ) -> Bool {
        guard #available(iOS 16.1, *) else { return false }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("[LiveActivity] ActivityAuthorizationInfo: areActivitiesEnabled is false")
            return false
        }

        let targetIndex = (!examples.isEmpty) ? (exampleIndex % examples.count) : 0
        let activeExample = (!examples.isEmpty) ? examples[targetIndex] : learningItem

        // Advance to next index for the next interval
        let nextIndex = (!examples.isEmpty) ? ((targetIndex + 1) % examples.count) : 0
        saveToDefaults(nextIndex, forKey: keyCurrentExampleIndex)
        saveToDefaults(Date().timeIntervalSince1970, forKey: keyLastSessionDate)

        let now = Date()
        let durationMins = max(1, durationMinutes)
        let endTime = Calendar.current.date(byAdding: .minute, value: durationMins, to: now) ?? now.addingTimeInterval(Double(durationMins * 60))

        let attributes = EnglishLearningAttributes(
            learningItem: learningItem,
            wordType: type,
            translation: translation,
            phonetic: phonetic,
            verbPresent: (verbPresent?.isEmpty ?? true) ? nil : verbPresent,
            verbPast: (verbPast?.isEmpty ?? true) ? nil : verbPast,
            verbParticiple: (verbParticiple?.isEmpty ?? true) ? nil : verbParticiple,
            categoryName: categoryName
        )

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let timeString = formatter.string(from: now)

        let state = EnglishLearningAttributes.ContentState(
            example: activeExample,
            exampleIndex: targetIndex + 1,
            totalExamples: max(1, examples.count),
            startTime: now,
            endTime: endTime,
            sessionTitle: "Sesión \(timeString)"
        )

        // End any existing activities first
        Task {
            for activity in Activity<EnglishLearningAttributes>.activities {
                await activity.end(using: state, dismissalPolicy: .immediate)
            }

            do {
                if #available(iOS 16.2, *) {
                    let content = ActivityContent(
                        state: state,
                        staleDate: endTime
                    )
                    let activity = try Activity.request(
                        attributes: attributes,
                        content: content,
                        pushType: nil
                    )
                    print("[LiveActivity] Started successfully (iOS 16.2+): \(activity.id)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(durationMins * 60)) {
                        Task {
                            await activity.end(using: state, dismissalPolicy: .after(endTime))
                        }
                    }
                } else {
                    let activity = try Activity.request(
                        attributes: attributes,
                        contentState: state,
                        pushType: nil
                    )
                    print("[LiveActivity] Started successfully (iOS 16.1): \(activity.id)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(durationMins * 60)) {
                        Task {
                            await activity.end(using: state, dismissalPolicy: .after(endTime))
                        }
                    }
                }
            } catch {
                print("[LiveActivity] Error starting Activity: \(error.localizedDescription)")
            }
        }

        return true
    }

    /// Dismisses any currently active Live Activity
    public func endCurrentActivity() {
        if #available(iOS 16.2, *) {
            Task {
                for activity in Activity<EnglishLearningAttributes>.activities {
                    await activity.end(nil, dismissalPolicy: .immediate)
                }
            }
        } else if #available(iOS 16.1, *) {
            Task {
                for activity in Activity<EnglishLearningAttributes>.activities {
                    await activity.end(dismissalPolicy: .immediate)
                }
            }
        }
    }

    /// Stops the daily learning routine, cancels schedules and clears data
    public func stopDayLearning() {
        endCurrentActivity()
        let defs = defaults
        defs?.set(false, forKey: keyActive)
        defs?.set("", forKey: keyWordEn)
        defs?.set("", forKey: keyWordEs)
        defs?.set("", forKey: keyPronunciation)
        defs?.set("[]", forKey: keyExamplesJson)
        defs?.set("", forKey: keyCardId)
        defs?.synchronize()

        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        internalTimer?.invalidate()
        internalTimer = nil
    }

    /// Retrieves current state for Flutter UI
    public func getActiveState() -> [String: Any] {
        let defs = defaults
        let isActive = defs?.bool(forKey: keyActive) ?? false
        let wordEn = defs?.string(forKey: keyWordEn) ?? ""
        let wordEs = defs?.string(forKey: keyWordEs) ?? ""
        let phonetic = defs?.string(forKey: keyPronunciation) ?? ""
        let type = defs?.string(forKey: keyType) ?? "PHRASE"
        let category = defs?.string(forKey: keyCategory) ?? ""
        let startHour = defs?.integer(forKey: keyStartHour) ?? 8
        let endHour = defs?.integer(forKey: keyEndHour) ?? 22
        let intervalMins = defs?.integer(forKey: keyIntervalMinutes) ?? 30
        let durationMins = defs?.integer(forKey: keyDurationMinutes) ?? 5
        let currentIdx = defs?.integer(forKey: keyCurrentExampleIndex) ?? 0
        let cardId = defs?.string(forKey: keyCardId) ?? ""

        var examples: [String] = []
        if let jsonStr = defs?.string(forKey: keyExamplesJson),
           let data = jsonStr.data(using: .utf8),
           let list = try? JSONDecoder().decode([String].self, from: data) {
            examples = list
        }

        var isCurrentlyLive = false
        if #available(iOS 16.1, *) {
            isCurrentlyLive = !Activity<EnglishLearningAttributes>.activities.isEmpty
        }

        return [
            "isActive": isActive,
            "isCurrentlyLive": isCurrentlyLive,
            "wordEn": wordEn,
            "wordEs": wordEs,
            "phonetic": phonetic,
            "type": type,
            "category": category,
            "examples": examples,
            "startHour": startHour,
            "endHour": endHour,
            "intervalMinutes": intervalMins,
            "durationMinutes": durationMins,
            "currentExampleIndex": currentIdx,
            "cardId": cardId
        ]
    }

    // MARK: - Scheduling Sessions (Background / Local Notifications)

    private func scheduleDaySessions(
        learningItem: String,
        examples: [String],
        startHour: Int,
        endHour: Int,
        intervalMinutes: Int,
        durationMinutes: Int
    ) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted else { return }

            let calendar = Calendar.current
            let now = Date()
            var exampleCounter = 0

            // Schedule triggers from startHour:00 to endHour:00 every intervalMinutes
            for hour in startHour...endHour {
                for minute in stride(from: 0, to: 60, by: max(15, intervalMinutes)) {
                    // Skip if after endHour:00
                    if hour == endHour && minute > 0 { break }

                    var dateComponents = DateComponents()
                    dateComponents.hour = hour
                    dateComponents.minute = minute

                    let exampleText = examples[exampleCounter % examples.count]
                    exampleCounter += 1

                    let content = UNMutableNotificationContent()
                    content.title = "📚 English Every Day: \(learningItem)"
                    content.body = "Ejemplo: \"\(exampleText)\" (Live Activity activa por \(durationMinutes) min)"
                    content.sound = .default
                    content.userInfo = [
                        "action": "start_live_activity_session",
                        "example": exampleText,
                        "learningItem": learningItem
                    ]

                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                    let identifier = "live_activity_session_\(hour)_\(minute)"
                    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                    center.add(request) { err in
                        if let err = err {
                            print("Error scheduling session notification: \(err.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}
#endif
