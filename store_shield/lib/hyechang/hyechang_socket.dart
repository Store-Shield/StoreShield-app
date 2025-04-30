import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:store_shield/socketURL.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket socket;
  final Map<String, Completer<dynamic>> _pendingRequests = {}; // 초기화됨
  bool _isConnected = false;

  // 싱글턴 패턴
  factory SocketService() {
    return _instance;
  }

  SocketService._internal();

  // 소켓 초기화
  Future<void> initSocket(String url) async {
    if (_isConnected) return;

    // 연결 완료를 기다리기 위한 Completer
    final completer = Completer<void>();

    socket = IO.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'forceNew': true,
    });

    socket.onConnect((_) {
      print('소켓 연결됨: $url');
      _isConnected = true;
      if (!completer.isCompleted) completer.complete();
    });

    socket.onError((error) {
      print('소켓 오류: $error');
      if (!completer.isCompleted) completer.completeError(error);
      _rejectAllPendingRequests('소켓 연결 오류: $error');
    });

    socket.onDisconnect((_) {
      print('소켓 연결 끊김');
      _isConnected = false;
      _rejectAllPendingRequests('소켓 연결 끊김');
    });

    // 메인 페이지 데이터 응답 리스너
    socket.on('mainPageResult', (data) {
      print('서버로부터 메인 페이지 데이터 수신: $data');
      _handleResponse('mainPageResult', data);
    });

    // 용의자 데이터 응답 리스너 추가
    socket.on('suspect_data', (data) {
      print('서버로부터 용의자 데이터 수신: $data');
      _handleResponse('suspect_data', data);
    });

    // 재고 알림 데이터 응답 리스너 추가
    socket.on('stock_data', (data) {
      print('서버로부터 재고 알림 데이터 수신: $data');
      _handleResponse('stock_data', data);
    });

    // 소켓 연결
    socket.connect();

    try {
      // 연결 완료 또는 오류 대기
      await completer.future.timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw Exception('소켓 연결 시간 초과');
    }
  }

  // 응답 처리 공통 함수
  void _handleResponse(String eventType, dynamic data) {
    if (_pendingRequests.containsKey(eventType)) {
      _pendingRequests[eventType]!.complete(data);
      _pendingRequests.remove(eventType);
    }
  }

  // 모든 대기 중인 요청 거부
  void _rejectAllPendingRequests(String reason) {
    _pendingRequests.forEach((_, completer) {
      if (!completer.isCompleted) {
        completer.completeError(reason);
      }
    });
    _pendingRequests.clear();
  }

  // 메인 페이지 데이터 요청
  Future<Map<String, dynamic>> getMainPageData() async {
    if (!_isConnected) {
      try {
        // 연결이 안된 경우 자동 재연결 시도
        const serverUrl = SocketConfig.socketURL;
        await initSocket(serverUrl);
      } catch (e) {
        throw Exception('소켓 연결 실패: $e');
      }
    }

    // 요청 데이터
    Map<String, dynamic> requestData = {
      'pageType': 'mainPage',
    };

    // Completer 생성
    Completer<dynamic> completer = Completer<dynamic>();
    _pendingRequests['mainPageResult'] = completer;

    // 이벤트 발송
    socket.emit('hyechangPageload', requestData);
    print('메인 페이지 데이터 요청: $requestData');

    // 타임아웃 설정하여 응답 대기
    try {
      final result =
          await completer.future.timeout(const Duration(seconds: 15));
      return result;
    } on TimeoutException {
      _pendingRequests.remove('mainPageResult');
      throw TimeoutException('서버 응답 시간 초과');
    }
  }

  // 알림 페이지 데이터 요청 (용의자 및 재고 알림)
  Future<Map<String, dynamic>> getAlertPageData() async {
    if (!_isConnected) {
      try {
        // 연결이 안된 경우 자동 재연결 시도
        const serverUrl = SocketConfig.socketURL;
        await initSocket(serverUrl);
      } catch (e) {
        throw Exception('소켓 연결 실패: $e');
      }
    }

    // 요청 데이터
    Map<String, dynamic> requestData = {
      'pageType': 'alertPage',
    };

    // Completer 생성 (용의자 및 재고 알림)
    Completer<dynamic> suspectCompleter = Completer<dynamic>();
    Completer<dynamic> stockCompleter = Completer<dynamic>();

    _pendingRequests['suspect_data'] = suspectCompleter;
    _pendingRequests['stock_data'] = stockCompleter;

    // 이벤트 발송
    socket.emit('hyechangPageload', requestData);
    print('알림 페이지 데이터 요청: $requestData');

    // 타임아웃 설정하여 응답 대기
    try {
      // 두 응답 모두 기다림
      final suspectResult =
          await suspectCompleter.future.timeout(const Duration(seconds: 15));
      final stockResult =
          await stockCompleter.future.timeout(const Duration(seconds: 15));

      return {
        'suspect_data': suspectResult ?? [],
        'stock_data': stockResult ?? []
      };
    } on TimeoutException {
      _pendingRequests.remove('suspect_data');
      _pendingRequests.remove('stock_data');
      throw TimeoutException('서버 응답 시간 초과 (알림 페이지 데이터)');
    } catch (e) {
      _pendingRequests.remove('suspect_data');
      _pendingRequests.remove('stock_data');
      print('알림 페이지 데이터 요청 오류: $e');
      // 오류 발생 시 빈 데이터 반환
      return {'suspect_data': [], 'stock_data': []};
    }
  }

  // 특정 연도의 용의자 데이터 요청
  Future<List<dynamic>> getYearSuspectData(int year) async {
    if (!_isConnected) {
      try {
        // 연결이 안된 경우 자동 재연결 시도
        const serverUrl = SocketConfig.socketURL;
        await initSocket(serverUrl);
      } catch (e) {
        throw Exception('소켓 연결 실패: $e');
      }
    }

    // 요청 데이터
    Map<String, dynamic> requestData = {
      'pageType': 'alertPage',
      'year': year,
    };

    // Completer 생성
    Completer<dynamic> completer = Completer<dynamic>();
    _pendingRequests['suspect_data'] = completer;

    // 이벤트 발송
    socket.emit('hyechangPageload', requestData);
    print('연도별 용의자 데이터 요청: $requestData ($year년)');

    // 타임아웃 설정하여 응답 대기
    try {
      final result =
          await completer.future.timeout(const Duration(seconds: 15));

      // 응답이 없거나 빈 배열인 경우 빈 배열 반환
      if (result == null) {
        return [];
      }

      return result;
    } on TimeoutException {
      _pendingRequests.remove('suspect_data');
      throw TimeoutException('서버 응답 시간 초과 (연도별 데이터)');
    } catch (e) {
      _pendingRequests.remove('suspect_data');
      print('연도별 데이터 요청 오류: $e');
      rethrow; // 상위 호출자에게 오류 전달
    }
  }

  // 소켓 연결 종료
  void dispose() {
    if (_isConnected) {
      socket.disconnect();
      _isConnected = false;
    }
  }
}