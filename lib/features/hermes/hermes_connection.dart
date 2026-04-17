import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Hermes Connection Service
/// ...
import 'package:web_socket_channel/web_socket_channel.dart';

/// Hermes Agent 连接服务
/// 负责与 Hermes Agent (云端/本地) 的实时通信
class HermesConnectionService {
  static final HermesConnectionService _instance = HermesConnectionService._internal();
  factory HermesConnectionService() => _instance;
  HermesConnectionService._internal();

  WebSocketChannel? _channel;
  bool _isConnected = false;
  String? _serverUrl;
  String _agentId = '';
  String _conversationId = '';

  final _messageController = StreamController<HermesMessage>.broadcast();
  final _connectionController = StreamController<ConnectionState>.broadcast();
  final _commandController = StreamController<ComputerCommand>.broadcast();

  Stream<HermesMessage> get messages => _messageController.stream;
  Stream<ConnectionState> get connectionState => _connectionController.stream;
  Stream<ComputerCommand> get commands => _commandController.stream;

  bool get isConnected => _isConnected;
  String get agentId => _agentId;

  /// 连接到 Hermes Agent
  /// 
  /// [serverUrl] 可以是：
  /// - ws://本地IP:8765 (本地 Hermes)
  /// - wss://云端.hermes.ai:443 (云端服务)
  Future<void> connect(String serverUrl) async {
    if (_isConnected) return;

    try {
      _serverUrl = serverUrl;
      _connectionController.add(ConnectionState.connecting());

      _channel = WebSocketChannel.connect(Uri.parse(serverUrl));

      // 监听消息
      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          debugPrint('Hermes 连接错误: $error');
          _connectionController.add(ConnectionState.error(error.toString()));
          _isConnected = false;
        },
        onDone: () {
          debugPrint('Hermes 连接关闭');
          _connectionController.add(ConnectionState.disconnected());
          _isConnected = false;
        },
      );

      // 发送连接请求
      _sendConnectRequest();
      
      _isConnected = true;
      _connectionController.add(ConnectionState.connected());

    } catch (e) {
      debugPrint('连接失败: $e');
      _connectionController.add(ConnectionState.error(e.toString()));
      _isConnected = false;
    }
  }

  /// 处理收到的消息
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final type = data['type'] as String?;

      switch (type) {
        case 'connect_response':
          _agentId = data['agent_id'] ?? '';
          _conversationId = data['conversation_id'] ?? '';
          debugPrint('已连接到 Hermes: $_agentId');
          break;

        case 'text':
          _messageController.add(HermesMessage.text(
            content: data['content'] ?? '',
            sender: data['sender'] ?? 'hermes',
            timestamp: DateTime.now(),
          ));
          
          // 检查是否是回复（Tina要说的话）
          if (data['sender']?.toString().toLowerCase() == 'tina' ||
              data['sender']?.toString().toLowerCase() == 'hermes') {
            // TTS 说话
            _speakInApp(data['content']);
          }
          break;

        case 'voice':
          // 收到语音命令
          _messageController.add(HermesMessage.voice(
            transcript: data['transcript'] ?? '',
            confidence: data['confidence'] ?? 1.0,
            language: data['language'] ?? 'zh-CN',
          ));
          break;

        case 'computer_command':
          // 收到电脑控制命令
          final command = data['command'] as Map<String, dynamic>?;
          if (command != null) {
            _commandController.add(ComputerCommand.fromJson(command));
          }
          break;

        case 'status':
          debugPrint('状态: ${data['status']}');
          break;

        case 'error':
          debugPrint('错误: ${data['message']}');
          break;

        default:
          debugPrint('未知消息类型: $type');
      }
    } catch (e) {
      debugPrint('消息解析错误: $e');
    }
  }

  /// 发送连接请求
  void _sendConnectRequest() {
    _send({
      'type': 'connect',
      'client': 'tina_jarvis_app',
      'version': '1.0.0',
      'platform': kIsWeb ? 'Web' : (Platform.isAndroid ? 'Android' : Platform.operatingSystem),
      'capabilities': [
        'voice_input',
        'voice_output',
        'computer_control',
        'wake_word',
      ],
    });
  }

  /// 发送语音消息给 Hermes
  Future<void> sendVoiceMessage(String transcript, {double confidence = 0.9}) async {
    _send({
      'type': 'voice_message',
      'transcript': transcript,
      'confidence': confidence,
      'language': 'zh-CN',
      'conversation_id': _conversationId,
    });
  }

  /// 发送文字消息给 Hermes
  Future<void> sendTextMessage(String text) async {
    _send({
      'type': 'text_message',
      'content': text,
      'sender': 'user',
      'conversation_id': _conversationId,
    });
  }

  /// 发送状态更新
  Future<void> sendStatus(String status, {Map<String, dynamic>? data}) async {
    _send({
      'type': 'status_update',
      'status': status,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// 发送电脑控制结果
  Future<void> sendCommandResult(String commandId, bool success, {String? result}) async {
    _send({
      'type': 'command_result',
      'command_id': commandId,
      'success': success,
      'result': result,
    });
  }

  /// 发送消息到服务器
  void _send(Map<String, dynamic> data) {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(jsonEncode(data));
    }
  }

  /// 在 App 内说话（TTS）
  void _speakInApp(String text) {
    // 这里会触发 TTS 服务
    // 实际会在 HomeScreen 中监听并调用 TTSService
    _messageController.add(HermesMessage.speakRequest(text));
  }

  /// 断开连接
  Future<void> disconnect() async {
    if (!_isConnected) return;
    
    _send({'type': 'disconnect'});
    await _channel?.sink.close();
    _isConnected = false;
    _connectionController.add(ConnectionState.disconnected());
  }

  /// 重连
  Future<void> reconnect() async {
    if (_serverUrl != null) {
      await disconnect();
      await connect(_serverUrl!);
    }
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _connectionController.close();
    _commandController.close();
  }
}

/// 连接状态
sealed class ConnectionState {
  const ConnectionState();
  
  factory ConnectionState.connecting() = ConnectingState;
  factory ConnectionState.connected() = ConnectedState;
  factory ConnectionState.disconnected() = DisconnectedState;
  factory ConnectionState.error(String message) = ErrorState;
}

class ConnectingState extends ConnectionState {
  const ConnectingState();
}

class ConnectedState extends ConnectionState {
  const ConnectedState();
}

class DisconnectedState extends ConnectionState {
  const DisconnectedState();
}

class ErrorState extends ConnectionState {
  final String message;
  const ErrorState(this.message);
}

/// Hermes 消息
sealed class HermesMessage {
  const HermesMessage();
  
  factory HermesMessage.text({
    required String content,
    required String sender,
    required DateTime timestamp,
  }) = TextMessage;
  
  factory HermesMessage.voice({
    required String transcript,
    required double confidence,
    required String language,
  }) = VoiceMessage;
  
  factory HermesMessage.speakRequest(String text) = SpeakRequestMessage;
}

class TextMessage extends HermesMessage {
  final String content;
  final String sender;
  final DateTime timestamp;
  const TextMessage({
    required this.content,
    required this.sender,
    required this.timestamp,
  });
}

class VoiceMessage extends HermesMessage {
  final String transcript;
  final double confidence;
  final String language;
  const VoiceMessage({
    required this.transcript,
    required this.confidence,
    required this.language,
  });
}

class SpeakRequestMessage extends HermesMessage {
  final String text;
  const SpeakRequestMessage(this.text);
}

/// 电脑控制命令
class ComputerCommand {
  final String id;
  final String type;  // 'open', 'run', 'shutdown', 'volume', etc.
  final String? path;
  final String? command;
  final Map<String, dynamic>? params;

  ComputerCommand({
    required this.id,
    required this.type,
    this.path,
    this.command,
    this.params,
  });

  factory ComputerCommand.fromJson(Map<String, dynamic> json) {
    return ComputerCommand(
      id: json['id'] ?? '',
      type: json['type'] ?? 'unknown',
      path: json['path'],
      command: json['command'],
      params: json['params'] as Map<String, dynamic>?,
    );
  }
}
