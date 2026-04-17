import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// 语音识别服务
class SpeechRecognitionService {
  static final SpeechRecognitionService _instance = SpeechRecognitionService._internal();
  factory SpeechRecognitionService() => _instance;
  SpeechRecognitionService._internal();

  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  String _lastWords = '';
  
  final _controller = StreamController<SpeechEvent>.broadcast();
  Stream<SpeechEvent> get events => _controller.stream;

  bool get isListening => _isListening;
  String get lastWords => _lastWords;

  /// 初始化语音识别
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      _isInitialized = await _speech.initialize(
        onError: (error) {
          debugPrint('语音识别错误: $error');
          _controller.add(SpeechEvent.error(error.toString()));
        },
        onStatus: (status) {
          debugPrint('语音识别状态: $status');
          if (status == 'done') {
            _isListening = false;
          }
        },
      );
      
      return _isInitialized;
    } catch (e) {
      debugPrint('初始化失败: $e');
      return false;
    }
  }

  /// 开始监听
  Future<void> startListening({
    required Function(String) onResult,
    Duration listenDuration = const Duration(seconds: 30),
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        _controller.add(SpeechEvent.error('语音识别初始化失败'));
        return;
      }
    }

    if (_isListening) {
      return;
    }

    _isListening = true;
    _currentWords = '';
    
    _controller.add(SpeechEvent.listening());

    await _speech.listen(
      onResult: (result) {
        _currentWords = result.recognizedWords;
        _lastWords = _currentWords;
        
        _controller.add(SpeechEvent.partial(_currentWords));
        
        if (result.finalResult) {
          _isListening = false;
          _controller.add(SpeechEvent.result(_currentWords));
          onResult(_currentWords);
        }
      },
      listenFor: listenDuration,
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      listenMode: ListenMode.confirmation,
      localeId: 'zh_CN', // 中文优先
    );
  }

  String _currentWords = '';

  /// 停止监听
  Future<void> stopListening() async {
    if (!_isListening) return;
    
    _isListening = false;
    await _speech.stop();
    _controller.add(SpeechEvent.stopped());
  }

  /// 检查是否可用
  Future<bool> isAvailable() async {
    return _speech.isAvailable;
  }

  void dispose() {
    _controller.close();
  }
}

/// 语音事件
sealed class SpeechEvent {
  const SpeechEvent();
  
  factory SpeechEvent.listening() = ListeningEvent;
  factory SpeechEvent.partial(String text) = PartialResultEvent;
  factory SpeechEvent.result(String text) = FinalResultEvent;
  factory SpeechEvent.error(String message) = ErrorEvent;
  factory SpeechEvent.stopped() = StoppedEvent;
}

class ListeningEvent extends SpeechEvent {
  const ListeningEvent();
}

class PartialResultEvent extends SpeechEvent {
  final String text;
  const PartialResultEvent(this.text);
}

class FinalResultEvent extends SpeechEvent {
  final String text;
  const FinalResultEvent(this.text);
}

class ErrorEvent extends SpeechEvent {
  final String message;
  const ErrorEvent(this.message);
}

class StoppedEvent extends SpeechEvent {
  const StoppedEvent();
}
