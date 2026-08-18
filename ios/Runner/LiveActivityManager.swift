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

    private var defaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupId)
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
            return ["success": false, "error": "Invalid learning item or examples"]
        }

        // Save Day Configuration
        let jsonExamples = (try? JSONEncoder().encode(examples)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        let defs = defaults
        defs?.set(true, forKey: keyActive)
        defs?.set(learningItem, forKey: keyWordEn)
        defs?.set(translation, forKey: keyWordEs)
        defs?.set(phonetic, forKey: keyPronunciation)
        defs?.set(type, forKey: keyType)
        defs?.set(categoryName, forKey: keyCategory)
        defs?.set(verbPresent ?? "", forKey: keyVerbPresent)
        defs?.set(verbPast ?? "", forKey: keyVerbPast)
        defs?.set(verbParticiple ?? "", forKey: keyVerbParticiple)
        defs?.set(jsonExamples, forKey: keyExamplesJson)
        defs?.set(startHour, forKey: keyStartHour)
        defs?.set(endHour, forKey: keyEndHour)
        defs?.set(intervalMinutes, forKey: keyIntervalMinutes)
        defs?.set(durationMinutes, forKey: keyDurationMinutes)
        defs?.set(0, forKey: keyCurrentExampleIndex)
        defs?.set(cardId, forKey: keyCardId)
        defs?.synchronize()

        // Schedule all notifications & background sessions for the day
        scheduleDaySessions(
            learningItem: learningItem,
            examples: examples,
            startHour: startHour,
            endHour: endHour,
            intervalMinutes: intervalMinutes,
            durationMinutes: durationMinutes
        )

        // Start first session immediately if within hours
        let started = startSession(exampleIndex: 0)
        
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
        guard #available(iOS 16.1, *) else { return false }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return false }

        let defs = defaults
        guard defs?.bool(forKey: keyActive) == true else { return false }

        let learningItem = defs?.string(forKey: keyWordEn) ?? ""
        let translation = defs?.string(forKey: keyWordEs) ?? ""
        let phonetic = defs?.string(forKey: keyPronunciation) ?? ""
        let type = defs?.string(forKey: keyType) ?? "PHRASE"
        let categoryName = defs?.string(forKey: keyCategory) ?? "English Every Day"
        let verbPresent = defs?.string(forKey: keyVerbPresent)
        let verbPast = defs?.string(forKey: keyVerbPast)
        let verbParticiple = defs?.string(forKey: keyVerbParticiple)
        let durationMins = max(1, defs?.integer(forKey: keyDurationMinutes) ?? 5)

        var examples: [String] = []
        if let jsonStr = defs?.string(forKey: keyExamplesJson),
           let data = jsonStr.data(using: .utf8),
           let list = try? JSONDecoder().decode([String].self, from: data),
           !list.isEmpty {
            examples = list
        } else {
            examples = ["Take care of yourself."]
        }

        let savedIdx = defs?.integer(forKey: keyCurrentExampleIndex) ?? 0
        let targetIndex = (exampleIndex ?? savedIdx) % examples.count
        let activeExample = examples[targetIndex]

        // Advance to next index for the next 30-min session
        let nextIndex = (targetIndex + 1) % examples.count
        defs?.set(nextIndex, forKey: keyCurrentExampleIndex)
        defs?.set(Date().timeIntervalSince1970, forKey: keyLastSessionDate)
        defs?.synchronize()

        let now = Date()
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
            totalExamples: examples.count,
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
                let content = ActivityContent(
                    state: state,
                    staleDate: endTime
                )
                let activity = try Activity.request(
                    attributes: attributes,
                    content: content,
                    pushType: nil
                )
                print("Live Activity started successfully: \(activity.id) with example: \(activeExample)")
                
                // Auto dismiss after duration expiration
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(durationMins * 60)) {
                    Task {
                        await activity.end(using: state, dismissalPolicy: .after(endTime))
                    }
                }
            } catch {
                print("Error starting Live Activity: \(error.localizedDescription)")
            }
        }

        return true
    }

    /// Dismisses any currently active Live Activity
    public func endCurrentActivity() {
        if #available(iOS 16.1, *) {
            Task {
                for activity in Activity<EnglishLearningAttributes>.activities {
                    await activity.end(nil, dismissalPolicy: .immediate)
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
