import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:store_shield/socketURL.dart';

// 싱글톤 소켓 서비스
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final String serverUrl = SocketConfig.socketURL;
  final _connectionStateListeners = <Function(bool)>[];
  bool _isConnected = false;
  bool _isInitialized = false;
  final Map<String, List<Function(dynamic)>> _eventListeners = {};

  bool get isConnected => _isConnected;

  void init() {
    // 이미 초기화되었다면 리스너들에게 현재 연결 상태만 알림
    if (_isInitialized) {
      _notifyConnectionStateChange(_isConnected);
      return;
    }

    _isInitialized = true;

    try {
      _socket = IO.io(
        serverUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setTimeout(20000)
            .build(),
      );

      // 자동 재연결 활성화
      _socket!.io.options?['reconnection'] = true;

      _setupEventHandlers();
      _socket!.connect();

      debugPrint('소켓 초기화 성공');
    } catch (e) {
      debugPrint('소켓 초기화 오류: $e');
      _isInitialized = false;
    }
  }

  void _setupEventHandlers() {
    _socket!.onConnect((_) {
      debugPrint('소켓 연결 성공');
      _isConnected = true;
      _notifyConnectionStateChange(true);
    });

    _socket!.onDisconnect((_) {
      debugPrint('소켓 연결 끊김');
      _isConnected = false;
      _notifyConnectionStateChange(false);
    });

    _socket!.onConnectError((error) {
      debugPrint('소켓 연결 에러: $error');
      _isConnected = false;
      _notifyConnectionStateChange(false);
    });

    _socket!.onError((error) {
      debugPrint('소켓 에러: $error');
    });
  }

  void addConnectionStateListener(Function(bool) listener) {
    if (!_connectionStateListeners.contains(listener)) {
      _connectionStateListeners.add(listener);
      // 즉시 현재 상태 알림
      listener(_isConnected);
    }
  }

  void removeConnectionStateListener(Function(bool) listener) {
    _connectionStateListeners.remove(listener);
  }

  void _notifyConnectionStateChange(bool connected) {
    for (final listener in List.from(_connectionStateListeners)) {
      try {
        listener(connected);
      } catch (e) {
        debugPrint('리스너 호출 중 오류: $e');
      }
    }
  }

  void emit(String event, [dynamic data]) {
    if (_socket != null && _isConnected) {
      _socket!.emit(event, data);
      debugPrint('이벤트 발행: $event');
    } else {
      debugPrint('소켓이 연결되지 않았습니다. 이벤트 큐잉: $event');
      // 연결되면 이벤트를 자동으로 발행하도록 리스너 등록
      if (_socket != null && !_isConnected) {
        void tempHandler(dynamic _) {
          debugPrint('재연결 후 큐잉된 이벤트 발행: $event');
          _socket!.emit(event, data);
          _socket!.off('connect', tempHandler);
        }

        _socket!.once('connect', tempHandler);
      }
    }
  }

  void on(String event, Function(dynamic) handler) {
    if (_socket != null) {
      _socket!.on(event, handler);
      debugPrint('이벤트 리스너 등록: $event');

      // 이벤트 리스너 추적
      _eventListeners[event] = _eventListeners[event] ?? [];
      _eventListeners[event]!.add(handler);
    }
  }

  void off(String event, [Function(dynamic)? handler]) {
    if (_socket != null) {
      if (handler != null) {
        _socket!.off(event, handler);
        // 특정 핸들러만 제거
        _eventListeners[event]?.remove(handler);
      } else {
        _socket!.off(event);
        // 해당 이벤트의 모든 핸들러 제거
        _eventListeners.remove(event);
      }
      debugPrint('이벤트 리스너 제거: $event');
    }
  }

  // 특정 페이지에서 등록한 모든 이벤트 리스너 제거
  void removeAllListeners() {
    if (_socket != null) {
      for (final event in _eventListeners.keys) {
        _socket!.off(event);
      }
      _eventListeners.clear();
      debugPrint('모든 이벤트 리스너 제거됨');
    }
  }

  // 앱 종료 시 호출할 메서드
  void dispose() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isInitialized = false;
      _isConnected = false;
    }
    _connectionStateListeners.clear();
    _eventListeners.clear();
    debugPrint('소켓 서비스 정리 완료');
  }

  // UI 테스트를 위한 목업 데이터 생성 메서드
  Map<String, List<Map<String, dynamic>>> getMockData() {
    return {
      'daily': List.generate(7, (i) => {'total': 50000.0 + (i * 5000)}),
      'monthly': List.generate(7, (i) => {'total': 200000.0 + (i * 30000)}),
      'yearly': List.generate(7, (i) => {'total': 2000000.0 + (i * 300000)}),
    };
  }
}
