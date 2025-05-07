import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../socket_service.dart';
import '../../fontstyle.dart';

class CctvPage extends StatefulWidget {
  const CctvPage({super.key});

  @override
  State<CctvPage> createState() => _CctvPageState();
}

class _CctvPageState extends State<CctvPage> {
  bool _isPlaying = false;
  bool _isConnected = false;
  bool _isLoading = true;
  bool _mounted = true;
  static const Color backgroundColor = Color.fromRGBO(242, 245, 253, 1);
  Uint8List? _imageData;
  final _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _socketService.init(); // 소켓 서비스 명시적 초기화 추가
    _socketService.addConnectionStateListener(_handleConnectionState);
    _setupSocketListeners(); // 바로 리스너 설정 (연결 상태와 무관하게)
    
    // 현재 연결 상태 확인
    if (_socketService.isConnected) {
      _handleConnectionState(true);
    }
  }

  void _handleConnectionState(bool connected) {
    if (!_mounted) return;

    setState(() {
      _isConnected = connected;
    });

    if (!connected) {
      setState(() {
        _isLoading = true;
      });
    }
  }

  void _setupSocketListeners() {
    _socketService.on('image_update', _onImageUpdate);
  }

  void _onImageUpdate(dynamic data) {
    if (!_mounted || !_isPlaying) return;

    final imageStr = data['image'] as String?;
    if (imageStr != null && imageStr.isNotEmpty) {
      final newImageData = _decodeBase64(imageStr);

      if (newImageData != null) {
        setState(() {
          _imageData = newImageData;
          _isLoading = false;
        });
      }
    }
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _isLoading = true;
      }
    });
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
    _mounted = false;
    _socketService.off('image_update', _onImageUpdate);
    _socketService.removeConnectionStateListener(_handleConnectionState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20), // 하단 모서리 둥글기 설정
          ),
        ),
        title: const StoreText(
          '실시간 CCTV',
          fontSize: 25,
          color: Color(0xFF16160F),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF16160F), size: 25),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.02),

              Expanded(
                child: SizedBox(
                  width: screenWidth,
                  child: AspectRatio(
                    aspectRatio: 0.54,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_isPlaying)
                          Container(
                            color: Colors.black,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (_imageData != null)
                                  RepaintBoundary(
                                    child: Image.memory(
                                      _imageData!,
                                      fit: BoxFit.contain,
                                      gaplessPlayback: true,
                                      filterQuality: FilterQuality.low,
                                      cacheWidth: screenWidth.toInt(),
                                    ),
                                  ),
                                if (_isLoading || !_isConnected)
                                  Container(
                                    color: Colors.black54,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (_isLoading)
                                            const CircularProgressIndicator(
                                                color: Colors.white),
                                          const SizedBox(height: 16),
                                          Text(
                                            _isLoading
                                                ? '영상 스트림 로딩 중...'
                                                : '서버에 연결할 수 없습니다',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        else
                          Image.network(
                            'https://cdn.builder.io/api/v1/image/assets/TEMP/691a735b4b55ede6813e629cfa922d6b756539cc?placeholderIfAbsent=true&apiKey=4ff31f8795cd4edc98e7741aaa589c6c',
                            fit: BoxFit.cover,
                            width: screenWidth,
                          ),

                        if (!_isPlaying)
                          GestureDetector(
                            onTap: _togglePlay,
                            child: Container(
                              width: screenWidth * 0.15,
                              height: screenWidth * 0.15,
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}