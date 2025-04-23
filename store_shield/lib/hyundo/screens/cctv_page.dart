import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'cctv_stream_view.dart';
import '../../mainPage.dart';

class CctvPage extends StatefulWidget {
  const CctvPage({Key? key}) : super(key: key);

  @override
  State<CctvPage> createState() => _CctvPageState();
}

class _CctvPageState extends State<CctvPage> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              // 커스텀 앱바 (높이 비율로 지정)
              // 앱바 Container 내부를 이렇게 수정
              Container(
                width: screenWidth,
                height: screenHeight * 0.14,
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(screenWidth * 0.06),
                    bottomRight: Radius.circular(screenWidth * 0.06),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.025), // 👈 적절한 간격
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // ← 뒤로가기 버튼 (MainPage 이동)
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const MainPage()),
                              );
                            },
                            child: Image.asset(
                              'lib/hyundo/assets/backBtnIcon.png',
                              width: screenWidth * 0.055,
                              fit: BoxFit.contain,
                            ),
                          ),

                          // 중앙 타이틀
                          Text(
                            '실시간 CCTV',
                            style: AppTheme.titleStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.045,
                            ),
                          ),

                          // → 홈 아이콘 (MainPage 이동)
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const MainPage()),
                              );
                            },
                            child: Image.asset(
                              'lib/hyundo/assets/mainPageIcon.png',
                              width: screenWidth * 0.055,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 간격
              SizedBox(height: screenHeight * 0.02),

              // CCTV 화면 영역
              Expanded(
                child: Container(
                  width: screenWidth,
                  child: AspectRatio(
                    aspectRatio: 0.54,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _isPlaying
                            ? const LiveCctvStreamView()
                            : Image.network(
                                'https://cdn.builder.io/api/v1/image/assets/TEMP/691a735b4b55ede6813e629cfa922d6b756539cc?placeholderIfAbsent=true&apiKey=4ff31f8795cd4edc98e7741aaa589c6c',
                                fit: BoxFit.cover,
                                width: screenWidth,
                              ),
                        if (!_isPlaying)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isPlaying = true;
                              });
                            },
                            child: Container(
                              width: 56,
                              height: 56,
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
  