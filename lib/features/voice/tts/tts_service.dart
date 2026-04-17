import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// 文字转语音服务
class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  double _volume = 1.0;
  double _pitch = 1.0;
  double _rate = 0.5;  // 语速

  final _controller = StreamController<TTSEvent>.broadcast();
  Stream<TTSEvent> get events => _controller.stream;

  bool get isSpeaking => _isSpeaking;

  /// 初始化 TTS
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setLanguage('zh-CN');
      await _flutterTts.setVolume(_volume);
      await _flutterTts.setPitch(_pitch);
      await _flutterTts.setSpeechRate(_rate);

      // 设置完成回调
      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        _controller.add(TTSEvent.completed());
      });

      // 设置开始回调
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        _controller.add(TTSEvent.started());
      });

      // 设置错误回调
      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        _controller.add(TTSEvent.error(msg.toString()));
      });

      _isInitialized = true;
       
    } catch (e) {
      debugPrint('TTS 初始化失败: $e');
    }
  }

  /// 说话
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (text.isEmpty) return;

    await _flutterTts.stop();  // 停止当前的
    await _flutterTts.speak(text);
  }

  /// 停止说话
  Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
  }

  /// 暂停
  Future<void> pause() async {
    await _flutterTts.pause();
  }

  /// 设置音量
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _flutterTts.setVolume(_volume);
  }

  /// 设置音调
  Future<void> setPitch(double pitch) async {
    _pitch = pitch;
    await _flutterTts.setPitch(pitch);
  }

  /// 设置语速
  Future<void> setRate(double rate) async {
    _rate = rate.clamp(0.0, 1.0);
    await _flutterTts.setSpeechRate(_rate);
  }

  /// 获取可用语音
  Future<List<String?>> getVoices() async {
    return await _flutterTts.getLanguages;
  }

  void dispose() {
    _controller.close();
    _flutterTts.stop();
  }
}

/// TTS 事件
sealed class TTSEvent {
  const TTSEvent();
  
  factory TTSEvent.started() = TTSStartedEvent;
  factory TTSEvent.completed() = TTSCompletedEvent;
  factory TTSEvent.error(String message) = TTSErrorEvent;
}

class TTSStartedEvent extends TTSEvent {
  const TTSStartedEvent();
}

class TTSCompletedEvent extends TTSEvent {
  const TTSCompletedEvent();
}

class TTSErrorEvent extends TTSEvent {
  final String message;
  const TTSErrorEvent(this.message);
}
