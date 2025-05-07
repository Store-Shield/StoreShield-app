import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'model/suspectorData.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../socketURL.dart';
import '../fontstyle.dart';

class SuspectDetailPage extends StatelessWidget {
  final SuspectData suspect;

  const SuspectDetailPage({super.key, required this.suspect});

  @override
  Widget build(BuildContext context) {
    // 도난 의심 제품 총 개수 계산
    final totalStolenItems = suspect.stolenItems.values
        .fold<int>(0, (previousValue, element) => previousValue + element);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20), // 하단 모서리 둥글기 설정
          ),
        ),
        title: const StoreText(
          '절도 용의자 정보',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Color(0xFF16160F)),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 용의자 정보 섹션
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: StoreText(
                      '절도 용의자 정보',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade800,
                    ),
                  ),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: suspect.getImage(width: 150, height: 150),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: StoreText(
                      'ID: ${suspect.id}',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // 도난 의심 제품 섹션
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StoreText(
                      '도난 의심 제품: 총 $totalStolenItems개',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade800,
                    ),
                    const SizedBox(height: 16),
                    ...suspect.stolenItems.entries.map((entry) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            // 제품 이미지
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 60,
                                height: 60,
                                child: suspect.getProductImage(
                                  entry.key,
                                  width: 60,
                                  height: 60,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // 제품 정보
                            Expanded(
                              child: StoreText(
                                entry.key,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            StoreText(
                              '개수: ${entry.value}',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // 증거 영상 섹션
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StoreText(
                      '증거영상',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade800,
                    ),
                    const SizedBox(height: 16),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: double.infinity,
                            height: 180,
                            color: Colors.grey.shade200,
                            child: suspect.getThumbnailImage(
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // 시간 표시
                        Positioned(
                          left: 12,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const StoreText(
                                  '입장:',
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                StoreText(
                                  DateFormat('HH:mm').format(suspect.comeIn),
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                const StoreText(
                                  ' - 퇴장:',
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                StoreText(
                                  DateFormat('HH:mm').format(suspect.comeOut),
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // 다운로드 버튼
                        // 다운로드 버튼
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.arrow_downward,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: () async {
                                try {
                                  // 서버 URL - 소켓 서비스와 동일한 기본 URL 사용
                                  const baseUrl = SocketConfig.socketURL;
                                  //일단 20
                                  final url =
                                      '$baseUrl/download_video/${suspect.id}';

                                  // 이전 방식 사용 (string 기반)
                                  if (await canLaunchUrlString(url)) {
                                    await launchUrlString(url);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('영상 다운로드가 시작되었습니다.')),
                                    );
                                  } else {
                                    throw '다운로드 URL을 열 수 없습니다';
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('영상 다운로드 실패: $e')),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 여백 추가
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
