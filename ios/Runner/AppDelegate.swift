import Flutter
import UIKit
import AVFAudio
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Local Notifications Plugin Callback & Delegate
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
            GeneratedPluginRegistrant.register(with: registry)
        }
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }

        // MARK: - Audio Session Config (CRÍTICA para TTS/Pronunciación)
        // Permite que la voz TTS nativa se reproduzca claramente
        // incluso si el usuario tiene el iPhone en modo silencioso.
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
                .playback,
                mode: .spokenAudio,
                policy: .longForm,
                options: [.mixWithOthers, .duckOthers, .allowBluetooth, .allowBluetoothA2DP]
            )
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            print("[AVAudioSession] Configurada como .playback + .spokenAudio.")
        } catch {
            print("[AVAudioSession] Error al configurar: \(error.localizedDescription)")
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    }
}
