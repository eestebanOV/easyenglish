import Flutter
import UIKit
import UserNotifications
import AVFAudio

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    private let CHANNEL_NAME = "com.easyenglish.app/live_activities"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // MARK: - Audio Session Config (CRÍTICA para TTS/Pronunciación)
        // iPhone tiene el switch lateral de "modo silencioso". Sin esta
        // configuración, la categoría por defecto (Ambient/SoloAmbient)
        // MUTEA COMPLETAMENTE el audio del TTS cuando el usuario tiene el
        // teléfono en silencio (incluso si sube el volumen por botones).
        // .playback = "soy una app de reproducción de audio (como Música)".
        // = reproduce incluso en modo silencioso, incluso con pantalla bloqueada.
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
                .playback,
                mode: .spokenAudio,
                policy: .longForm,
                options: [.mixWithOthers, .duckOthers, .allowBluetooth, .allowBluetoothA2DP]
            )
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            print("[AVAudioSession] Configurada como .playback + .spokenAudio → TTS sonará incluso en modo silencioso.")
        } catch {
            print("[AVAudioSession] Error al configurar: \(error.localizedDescription)")
        }

        // MARK: - UNUserNotificationCenter Delegate (CRÍTICO: setear ANTES que cualquier plugin Flutter)
        // El delegado debe setearse UNA VEZ al arranque; si flutter_tts o flutter_local_notifications
        // sobrescriben el delegado perderemos el evento willPresent y las notificaciones en foreground
        // aparecerán MUTADAS (sin banner ni sonido).
        let nc = UNUserNotificationCenter.current()
        LocalNotificationManager.shared.installNotificationDelegate()
        nc.requestAuthorization(options: [.alert, .sound, .badge, .provisional]) { granted, err in
            if let err = err {
                print("[AppDelegate] UNUserNotification auth error: \(err.localizedDescription)")
            } else {
                print("[AppDelegate] UNUserNotification auth granted=\(granted)")
            }
        }
        // Opcional: definir categoría LEARNING_CATEGORY por si en el futuro queremos acciones
        let learnCategory = UNNotificationCategory(
            identifier: "LEARNING_CATEGORY",
            actions: [],
            intentIdentifiers: [],
            options: [.hiddenPreviewsShowTitle, .hiddenPreviewsShowSubtitle]
        )
        nc.setNotificationCategories([learnCategory])

        if let controller = window?.rootViewController as? FlutterViewController {
            setupDailyLearningChannel(binaryMessenger: controller.binaryMessenger)
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    }

    private func setupDailyLearningChannel(binaryMessenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: binaryMessenger)

        channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
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
                let cardId = args["cardId"] as? String ?? ""

                let response = LocalNotificationManager.shared.startDayLearning(
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
                    cardId: cardId
                )
                result(response)

            case "startSessionNow":
                let args = call.arguments as? [String: Any]
                let exampleIndex = args?["exampleIndex"] as? Int
                let response = LocalNotificationManager.shared.triggerImmediateNotification(exampleIndex: exampleIndex)
                result(response)

            case "endCurrentActivity":
                LocalNotificationManager.shared.stopDayLearning()
                result(["success": true])

            case "stopDayLearning":
                LocalNotificationManager.shared.stopDayLearning()
                result(["success": true])

            case "getActiveState":
                let state = LocalNotificationManager.shared.getActiveState()
                result(state)

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
}
