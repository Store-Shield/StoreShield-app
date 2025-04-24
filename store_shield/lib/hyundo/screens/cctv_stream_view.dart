import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import './socket_service.dart';

class LiveCctvStreamView extends StatefulWidget {
  const LiveCctvStreamView({super.key});

  @override
  State<LiveCctvStreamView> createState() => _LiveCctvStreamViewState();
}

class _LiveCctvStreamViewState extends State<LiveCctvStreamView>
    with SingleTickerProviderStateMixin {
  final _socketService = SocketService();
  Uint8List? _imageData;
  bool _isLoading = true;
  bool _isConnected = false;
  final Image _placeholderImage =
      Image.asset('assets/placeholder.png'); // 필요한 경우 추가

  @override
  void initState() {
    super.initState();
    _connectAndStream();
  }

  Future<void> _connectAndStream() async {
    _socketService.addConnectionStateListener(_handleConnection);
  }

  void _handleConnection(bool connected) {
    setState(() {
      _isConnected = connected;
    });

    if (connected) {
      _socketService.on('image_update', _onImageUpdate);
    } else {
      _socketService.off('image_update', _onImageUpdate);
    }
  }

  void _onImageUpdate(dynamic data) {
    if (!mounted) return;

    final imageStr = data['image'] as String?;
    if (imageStr != null && imageStr.isNotEmpty) {
      final newImageData = _decodeBase64(imageStr);

      if (newImageData != null) {
        if (_isLoading) {
          setState(() {
            _imageData = newImageData;
            _isLoading = false;
          });
        } else {
          // 로딩이 끝난 후에는 setState 호출을 최소화하여 리빌드 횟수 줄이기
          if (mounted) {
            setState(() {
              _imageData = newImageData;
            });
          }
        }
      }
    }
  }

  Uint8List? _decodeBase64(String base64Str) {
    try {
      if (base64Str.startsWith('data:image')) {
        base64Str = base64Str.split(',').last;
      }
      return base64Decode(base64Str.replaceAll(RegExp(r'\s+'), ''));
    } catch (e) {
      print('이미지 디코딩 오류: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _socketService.removeConnectionStateListener(_handleConnection);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 실시간 영상 표시
          if (_imageData != null)
            RepaintBoundary(
              child: Image.memory(
                _imageData!,
                fit: BoxFit.contain,
                gaplessPlayback: true, // 이미지 간 깜빡임 방지
                filterQuality: FilterQuality.low, // 렌더링 속도 향상
                cacheWidth: MediaQuery.of(context)
                    .size
                    .width
                    .toInt(), // 화면 크기에 맞게 메모리 최적화
              ),
            ),

          // 로딩 상태나 연결 오류 표시
          if (_isLoading || !_isConnected)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLoading)
                      const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      _isLoading
                          ? '영상 스트림 로딩 중...'
                          : (_isConnected ? '' : '서버 연결 대기 중...'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
