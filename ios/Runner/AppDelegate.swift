import Flutter
import UIKit
#if canImport(ActivityKit)
import ActivityKit
#endif
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    private let CHANNEL_NAME = "com.easyenglish.app/live_activities"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        let liveActivityChannel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: controller.binaryMessenger)

        liveActivityChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "startDayLearning":
                guard let args = call.arguments as? [String: Any],
                      let learningItem = args["learningItem"] as? String,
                      let type = args["type"] as? String,
                      let translation = args["translation"] as? String,
                      let phonetic = args["phonetic"] as? String,
                      let examples = args["examples"] as? [String] else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Missing required parameters", details: nil))
                    return
                }

                let verbPresent = args["verbPresent"] as? String
                let verbPast = args["verbPast"] as? String
                let verbParticiple = args["verbParticiple"] as? String
                let categoryName = args["categoryName"] as? String ?? "English Every Day"
                let startHour = args["startHour"] as? Int ?? 8
                let endHour = args["endHour"] as? Int ?? 22
                let intervalMinutes = args["intervalMinutes"] as? Int ?? 30
                let durationMinutes = args["durationMinutes"] as? Int ?? 5
                let cardId = args["cardId"] as? String ?? ""

                let response = LiveActivityManager.shared.startDayLearning(
                    learningItem: learningItem,
                    type: type,
                    translation: translation,
                    phonetic: phonetic,
                    examples: examples,
                    verbPresent: verbPresent,
                    verbPast: verbPast,
                    verbParticiple: verbParticiple,
                    categoryName: categoryName,
                    startHour: startHour,
                    endHour: endHour,
                    intervalMinutes: intervalMinutes,
                    durationMinutes: durationMinutes,
                    cardId: cardId
                )
                result(response)

            case "startSessionNow":
                let args = call.arguments as? [String: Any]
                let exampleIndex = args?["exampleIndex"] as? Int
                let success = LiveActivityManager.shared.startSession(exampleIndex: exampleIndex)
                result(["success": success])

            case "endCurrentActivity":
                LiveActivityManager.shared.endCurrentActivity()
                result(["success": true])

            case "stopDayLearning":
                LiveActivityManager.shared.stopDayLearning()
                result(["success": true])

            case "getActiveState":
                let state = LiveActivityManager.shared.getActiveState()
                result(state)

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        UNUserNotificationCenter.current().delegate = self

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    }

    // Handle background notification triggers
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Trigger live activity when notification arrives in foreground
        LiveActivityManager.shared.startSession()
        completionHandler([.banner, .sound, .badge])
    }

    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Trigger live activity when user interacts with notification
        LiveActivityManager.shared.startSession()
        completionHandler()
    }
}
