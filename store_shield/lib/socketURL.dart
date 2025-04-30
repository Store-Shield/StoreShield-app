// socketURL.dart
class SocketConfig {
  // 정적 문자열 변수로 socket.url 정의
  static const String socketURL = "https://d9fd-49-170-80-119.ngrok-free.app";
  // 필요한 경우 URL을 가져오는 메서드
  static String getSocketURL() {
    return socketURL;
  }
}
