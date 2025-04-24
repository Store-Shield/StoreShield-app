import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'model/suspectorData.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'fontstyle.dart';

class SuspectDetailPage extends StatelessWidget {
  final SuspectData suspect;

  const SuspectDetailPage({super.key, required this.suspect});

  @override
  Widget build(BuildContext context) {
    // 도난 의심 제품 총 개수 계산
    final totalStolenItems = suspect.stolenItems.values
        .fold<int>(0, (previousValue, element) => previousValue + element);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight), // 앱바만의 높이
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            title: StoreText(
              '절도 용의자 정보',
              fontSize: screenWidth * 0.05,
            ),
            centerTitle: true,
            backgroundColor: Colors.white, // 배경색 고정
            elevation: 0,
            // TabBar를 제거
          ),
        ),
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
                      '절도 의심자 정보',
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
                        // 섬네일 이미지
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: double.infinity,
                            height: 180,
                            color: Colors.grey.shade200,
                            child: suspect.thumbnail != null
                                ? Image.memory(
                                    base64Decode(suspect
                                        .getBase64String(suspect.thumbnail!)),
                                    fit: BoxFit.cover,
                                  )
                                : const Center(
                                    child: Icon(Icons.videocam_off,
                                        size: 50, color: Colors.grey),
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
                                  const baseUrl =
                                      'https://8529-175-214-112-154.ngrok-free.app';
                                  //일단 20
                                  const url = '$baseUrl/download_video/20';

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
