import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Android / 鸿蒙原生桥接。
class SpeechInputBridge {
  SpeechInputBridge._();

  static const _channel = MethodChannel('com.stday.stday/speech_input');

  static Future<bool> isRecognitionAvailable() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    try {
      return await _channel.invokeMethod<bool>('isRecognitionAvailable') ??
          false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> canStartIntentRecognition() async {
    if (defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      return await _channel.invokeMethod<bool>('canStartIntentRecognition') ??
          false;
    } catch (_) {
      return false;
    }
  }

  /// 华为 / 鸿蒙优先走系统语音弹窗，避免 speech_to_text 原生崩溃。
  static Future<bool> shouldPreferIntentRecognition() async {
    if (defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      final huawei =
          await _channel.invokeMethod<bool>('isHuaweiFamily') ?? false;
      final harmony = await _channel.invokeMethod<bool>('isHarmonyOs') ?? false;
      return huawei || harmony;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> startIntentRecognition({String? prompt}) async {
    try {
      return await _channel.invokeMethod<String>(
        'startIntentRecognition',
        {'prompt': prompt},
      );
    } on PlatformException catch (e) {
      if (e.code == 'UNAVAILABLE') return null;
      rethrow;
    }
  }
}
