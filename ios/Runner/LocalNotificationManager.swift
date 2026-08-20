import Foundation
import UserNotifications
import UIKit

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
    }

    public func installNotificationDelegate() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        print("[LocalNotifications] UNUserNotificationCenter delegate instalado: LocalNotificationManager.shared")
    }

    // MARK: - Helpers asíncronos (completion)
    private func withAuthorizedCenter(_ work: @escaping (_ center: UNUserNotificationCenter) -> Void, onDenied: (() -> Void)? = nil) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                DispatchQueue.main.async { work(center) }
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, err in
                    if let err = err {
                        print("[LocalNotifications] Auth error: \(err.localizedDescription)")
                    }
                    DispatchQueue.main.async {
                        if granted {
                            work(center)
                        } else {
                            onDenied?()
                        }
                    }
                }
            case .denied, .ephemeral:
                print("[LocalNotifications] Permiso de notificaciones DENEGADO. El usuario debe activarlo en Ajustes > EasyEnglish > Notificaciones")
                DispatchQueue.main.async { onDenied?() }
            @unknown default:
                DispatchQueue.main.async { onDenied?() }
            }
        }
    }

    public func requestAuthorizationIfNeeded(completion: ((_ granted: Bool) -> Void)? = nil) {
        withAuthorizedCenter({ _ in
            DispatchQueue.main.async { completion?(true) }
        }, onDenied: {
            DispatchQueue.main.async { completion?(false) }
        })
    }

    // MARK: - Public API

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
        cardId: String = "",
        completion: @escaping ([String: Any]) -> Void
    ) {
        guard !learningItem.isEmpty, !examples.isEmpty else {
            print("[LocalNotifications] Error: Invalid learning item or examples")
            DispatchQueue.main.async {
                completion(["success": false, "error": "Invalid learning item or examples", "pendingNotifications": 0])
            }
            return
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

        let responseBuilder: (_ authorized: Bool, _ pending: Int) -> [String: Any] = { authorized, pending in
            print("[LocalNotifications] startDayLearning. scheduled=\(pending). autorizado=\(authorized). item='\(learningItem)', interval=\(intervalMinutes)min, start=\(startHour), end=\(endHour)")
            return [
                "success": authorized,
                "authorized": authorized,
                "learningItem": learningItem,
                "totalExamples": examples.count,
                "intervalMinutes": intervalMinutes,
                "startHour": startHour,
                "endHour": endHour,
                "pendingNotifications": pending
            ]
        }

        withAuthorizedCenter({ center in
            self.clearScheduledDailyNotifications(center: center) {
                self.scheduleDayNotificationsInternal(
                    center: center,
                    learningItem: learningItem,
                    translation: translation,
                    phonetic: phonetic,
                    type: type,
                    examples: examples,
                    startHour: startHour,
                    endHour: endHour,
                    intervalMinutes: intervalMinutes
                ) { _, err in
                    if let err = err {
                        print("[LocalNotifications] Error al añadir notification request: \(err.localizedDescription)")
                    }
                } onComplete: { scheduledCount in
                    self.logPendingNotificationRequests(center: center, context: "startDayLearning completion") {
                        DispatchQueue.main.async {
                            completion(responseBuilder(true, scheduledCount))
                        }
                    }
                }
            }
        }, onDenied: {
            DispatchQueue.main.async {
                completion(responseBuilder(false, 0))
            }
        })
    }

    public func triggerImmediateNotification(
        exampleIndex: Int? = nil,
        completion: @escaping ([String: Any]) -> Void
    ) {
        guard getBool(forKey: keyActive) else {
            DispatchQueue.main.async {
                completion(["success": false, "error": "Daily learning is not active", "authorized": false])
            }
            return
        }

        let learningItem = getString(forKey: keyWordEn) ?? ""
        let translation = getString(forKey: keyWordEs) ?? ""
        let phonetic = getString(forKey: keyPronunciation) ?? ""

        var examples: [String] = []
        if let jsonStr = getString(forKey: keyExamplesJson),
           let data = jsonStr.data(using: .utf8),
           let list = try? JSONDecoder().decode([String].self, from: data),
           !list.isEmpty {
            examples = list
        } else {
            DispatchQueue.main.async {
                completion(["success": false, "error": "No examples saved", "authorized": false])
            }
            return
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
        content.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
        content.userInfo = [
            "action": "manual_learning_notification",
            "learningItem": learningItem,
            "example": exampleText,
            "exampleIndex": targetIndex,
            "totalExamples": examples.count
        ]
        content.threadIdentifier = "easyenglish_daily_learning"
        content.categoryIdentifier = "LEARNING_CATEGORY"

        let finish: (_ success: Bool) -> Void = { success in
            let nextIndex = (targetIndex + 1) % examples.count
            self.saveToDefaults(nextIndex, forKey: self.keyCurrentExampleIndex)
            DispatchQueue.main.async {
                completion([
                    "success": success,
                    "example": exampleText,
                    "index": targetIndex,
                    "authorized": success
                ])
            }
        }

        withAuthorizedCenter({ center in
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(
                identifier: "\(self.notificationPrefixId)immediate_\(Date().timeIntervalSince1970)",
                content: content,
                trigger: trigger
            )
            print("[LocalNotifications] Intentando programar inmediata id=\(request.identifier)")
            center.add(request) { err in
                if let err = err {
                    print("[LocalNotifications] Immediate error: \(err.localizedDescription)")
                    finish(false)
                } else {
                    print("[LocalNotifications] Notificación inmediata programada correctamente id=\(request.identifier)")
                    finish(true)
                }
            }
        }, onDenied: {
            finish(false)
        })
    }

    public func stopDayLearning() {
        withAuthorizedCenter({ center in
            self.clearScheduledDailyNotifications(center: center) {
                print("[LocalNotifications] stopDayLearning: notificaciones programadas canceladas")
            }
        })

        let defs = defaults
        defs.set(false, forKey: keyActive)
        defs.set("", forKey: keyWordEn)
        defs.set("", forKey: keyWordEs)
        defs.set("", forKey: keyPronunciation)
        defs.set("[]", forKey: keyExamplesJson)
        defs.set("", forKey: keyCardId)
        defs.synchronize()

        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }

    public func getActiveState(completion: @escaping ([String: Any]) -> Void) {
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

        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let pendingCount = requests.filter { $0.identifier.hasPrefix(self.notificationPrefixId) }.count
            print("[LocalNotifications] getActiveState: \(pendingCount) notificaciones programadas pendientes")
            DispatchQueue.main.async {
                completion([
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
                ])
            }
        }
    }

    // MARK: - Private Helpers (seguros)

    private func clearScheduledDailyNotifications(center: UNUserNotificationCenter, done: @escaping () -> Void) {
        center.getPendingNotificationRequests { requests in
            let ids = requests
                .map { $0.identifier }
                .filter { $0.hasPrefix(self.notificationPrefixId) }
            if !ids.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: ids)
                center.removeDeliveredNotifications(withIdentifiers: ids)
                print("[LocalNotifications] Canceladas \(ids.count) notificaciones previas con prefijo \(self.notificationPrefixId)")
            }
            DispatchQueue.main.async { done() }
        }
    }

    private func logPendingNotificationRequests(
        center: UNUserNotificationCenter,
        context: String,
        done: (() -> Void)? = nil
    ) {
        center.getPendingNotificationRequests { requests in
            let ids = requests
                .map { $0.identifier }
                .filter { $0.hasPrefix(self.notificationPrefixId) }
                .sorted()
            print("[LocalNotifications] \(context): pendingIds=\(ids), scheduledCount=\(ids.count)")
            DispatchQueue.main.async { done?() }
        }
    }

    private func scheduleDayNotificationsInternal(
        center: UNUserNotificationCenter,
        learningItem: String,
        translation: String,
        phonetic: String,
        type: String,
        examples: [String],
        startHour: Int,
        endHour: Int,
        intervalMinutes: Int,
        onPerRequestError: @escaping (_ identifier: String, _ error: Error?) -> Void,
        onComplete: @escaping (_ scheduledCount: Int) -> Void
    ) {
        let calendar = Calendar.current
        let now = Date()
        let safeInterval = max(5, intervalMinutes)

        var exampleCounter = 0
        var requestsToSchedule: [(identifier: String, request: UNNotificationRequest, scheduledDate: Date)] = []

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
            dateComponents.calendar = calendar
            dateComponents.timeZone = .current
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

            if let scheduledDate = calendar.nextDate(
                after: calendar.startOfDay(for: now),
                matching: dateComponents,
                matchingPolicy: .nextTime
            ) {
                if scheduledDate <= now {
                    continue
                }

                var triggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: scheduledDate)
                triggerComponents.calendar = calendar
                triggerComponents.timeZone = .current
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                requestsToSchedule.append((identifier: identifier, request: request, scheduledDate: scheduledDate))
            }
        }

        saveToDefaults(0, forKey: keyCurrentExampleIndex)

        if requestsToSchedule.isEmpty {
            print("[LocalNotifications] scheduleDayNotificationsInternal: 0 notificaciones candidatas para programar.")
            onComplete(0)
            return
        }

        let completionLock = NSLock()
        let group = DispatchGroup()
        var scheduledCount = 0

        for entry in requestsToSchedule {
            group.enter()
            print("[LocalNotifications] Scheduling request id=\(entry.identifier) date=\(entry.scheduledDate) userInfo=\(entry.request.content.userInfo)")
            DispatchQueue.main.async {
                center.add(entry.request) { err in
                    completionLock.lock()
                    if let err = err {
                        print("[LocalNotifications] Error scheduling \(entry.identifier): \(err.localizedDescription)")
                    } else {
                        scheduledCount += 1
                        print("[LocalNotifications] Scheduled OK id=\(entry.identifier)")
                    }
                    completionLock.unlock()
                    onPerRequestError(entry.identifier, err)
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            print("[LocalNotifications] scheduleDayNotificationsInternal: \(scheduledCount) notificaciones programadas correctamente.")
            onComplete(scheduledCount)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension LocalNotificationManager: UNUserNotificationCenterDelegate {
    // ENSEÑAMOS LA NOTIFICACIÓN INCLUSO SI EL USUARIO TIENE LA APP EN PRIMER PLANO
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("[LocalNotifications] willPresent notification id=\(notification.request.identifier) title=\(notification.request.content.title)")
        completionHandler([.banner, .sound])
    }

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let info = response.notification.request.content.userInfo
        print("[LocalNotifications] didReceive response id=\(response.notification.request.identifier), action=\(info["action"] ?? "")")
        completionHandler()
    }
}
