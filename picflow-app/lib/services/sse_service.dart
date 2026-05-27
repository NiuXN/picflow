import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../config/api_config.dart';

/// SSE 服务——与后端建立长连接，实时接收通知推送
class SseService {
  HttpClient? _client;
  StreamSubscription? _subscription;
  bool _connected = false;

  /// 通知到达回调
  void Function(Map<String, dynamic> notification)? onNotification;

  /// 连接状态变更回调
  void Function(bool connected)? onConnectionChange;

  /// 是否已连接
  bool get isConnected => _connected;

  /// 建立 SSE 连接
  Future<void> connect() async {
    await disconnect();

    try {
      _client = HttpClient();
      final uri = Uri.parse('${ApiConfig.baseUrl}/sse/subscribe');
      final request = await _client!.getUrl(uri);
      request.headers.set('Accept', 'text/event-stream');
      request.headers.set('Cache-Control', 'no-cache');

      final response = await request.close();
      _connected = true;
      onConnectionChange?.call(true);

      // 解析 SSE 数据流
      final stream = response.transform(utf8.decoder);
      String buffer = '';

      _subscription = stream.listen(
        (data) {
          buffer += data;
          _parseEvents(buffer);
        },
        onError: (_) => _handleDisconnect(),
        onDone: () => _handleDisconnect(),
        cancelOnError: false,
      );
    } catch (_) {
      _handleDisconnect();
      // 连接失败 3s 后重试
      Future.delayed(const Duration(seconds: 3), connect);
    }
  }

  /// 断开 SSE 连接
  Future<void> disconnect() async {
    _connected = false;
    await _subscription?.cancel();
    _subscription = null;
    _client?.close();
    _client = null;
    onConnectionChange?.call(false);
  }

  /// 解析 SSE 事件流
  void _parseEvents(String buffer) {
    final lines = buffer.split('\n');
    String? eventType;
    String? eventData;

    for (final line in lines) {
      if (line.startsWith('event: ')) {
        eventType = line.substring(7).trim();
      } else if (line.startsWith('data: ')) {
        eventData = line.substring(6).trim();
      } else if (line.isEmpty && eventData != null) {
        // 空行表示事件结束
        if (eventType == 'notification' && onNotification != null) {
          try {
            final json = jsonDecode(eventData) as Map<String, dynamic>;
            onNotification?.call(json);
          } catch (_) {}
        }
        eventType = null;
        eventData = null;
      }
    }
  }

  void _handleDisconnect() {
    _connected = false;
    onConnectionChange?.call(false);
    // 断开后 5s 自动重连
    Future.delayed(const Duration(seconds: 5), () {
      if (!_connected) connect();
    });
  }
}
