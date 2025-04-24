import 'package:flutter/material.dart';
import 'cctv_stream_view.dart';
import '../../mainPage.dart';
import '../../hyechang/fontstyle.dart';

class CctvPage extends StatefulWidget {
  const CctvPage({super.key});

  @override
  State<CctvPage> createState() => _CctvPageState();
}

class _CctvPageState extends State<CctvPage> {
  bool _isPlaying = false;
  static const Color backgroundColor = Color.fromRGBO(242, 245, 253, 1);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
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
                  color: Colors.white,
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
                      padding: EdgeInsets.only(bottom: screenHeight * 0.025),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Center text (absolute center of the container)
                          Align(
                            alignment: Alignment.center,
                            child: StoreText(
                              '실시간 CCTV',
                              fontSize: screenWidth * 0.045,
                            ),
                          ),

                          // Left-aligned back button
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Image.asset(
                                'lib/hyundo/assets/backBtnIcon.png',
                                width: screenWidth * 0.055,
                                fit: BoxFit.contain,
                              ),
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
                child: SizedBox(
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
