import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // Configuración CRÍTICA para iOS:
      // - IosTextToSpeechAudioCategory.playback = reproduce incluso con
      //   el botón de SILENCIO activado (interruptor lateral del iPhone).
      // - IosTextToSpeechAudioMode.spokenAudio = optimizado para voz/TTS.
      // - IosTextToSpeechAudioCategoryOptions = baja volumen de otras apps
      //   mientras hablamos (ducking) y permite mezclar audio en segundo plano.
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        try {
          await _flutterTts.setIosAudioCategory(
            IosTextToSpeechAudioCategory.playback,
            [
              IosTextToSpeechAudioCategoryOptions.allowBluetooth,
              IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
              IosTextToSpeechAudioCategoryOptions.mixWithOthers,
              IosTextToSpeechAudioCategoryOptions.duckOthers,
            ],
            IosTextToSpeechAudioMode.spokenAudio,
          );
          // Fuerza a que el audio se dirija al altavoz inferior (no al auricular).
          await _flutterTts.awaitSpeakCompletion(true);
        } catch (e) {
          debugPrint('TTS iOS audio category config fallback: $e');
        }
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS Init Error: $e');
    }
  }

  Future<void> speak(String text) async {
    try {
      if (!_isInitialized) {
        await init();
      }
      // Reinicializa la categoría por si el sistema la cambió después de
      // reproducir otro audio (Spotify, llamada, etc.).
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        try {
          await _flutterTts.setIosAudioCategory(
            IosTextToSpeechAudioCategory.playback,
            [
              IosTextToSpeechAudioCategoryOptions.allowBluetooth,
              IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
              IosTextToSpeechAudioCategoryOptions.mixWithOthers,
              IosTextToSpeechAudioCategoryOptions.duckOthers,
            ],
            IosTextToSpeechAudioMode.spokenAudio,
          );
        } catch (_) {}
      }
      await _flutterTts.stop();
      if (text.trim().isNotEmpty) {
        await _flutterTts.speak(text);
      }
    } catch (e) {
      debugPrint('TTS Speak Error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('TTS Stop Error: $e');
    }
  }
}
