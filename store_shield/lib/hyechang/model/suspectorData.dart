import 'dart:convert';
import 'package:flutter/material.dart';

class SuspectData {
  final int id;
  final DateTime comeIn; // 입장 시간
  final DateTime comeOut; // 퇴장 시간
  final String calState; // 상태 (도난 의심)
  final String customerImage; // 고객 이미지 BASE64 문자열
  final Map<String, int> stolenItems; // 도난 의심 제품 (제품명: 수량)
  final Map<String, String> stolenItemImages; // 도난 의심 제품 이미지 (제품명: BASE64 이미지)
  final String? thumbnail; // 섬네일 이미지 BASE64 문자열

  SuspectData({
    required this.id,
    required this.comeIn,
    required this.comeOut,
    required this.calState,
    required this.customerImage,
    required this.stolenItems,
    required this.stolenItemImages,
    this.thumbnail,
  });

  // BASE64 이미지를 디코딩하여 Image 위젯 반환
  Widget getImage({double? width, double? height, BoxFit fit = BoxFit.cover}) {
    try {
      return Image.memory(
        base64Decode(getBase64String(customerImage)),
        width: width,
        height: height,
        fit: fit,
      );
    } catch (e) {
      // 이미지 디코딩 오류 시 기본 이미지 표시
      return Icon(Icons.person, size: width ?? 100);
    }
  }

  Widget getThumbnailImage(
      {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (thumbnail == null || thumbnail!.isEmpty) {
      // 썸네일이 없는 경우 에셋 이미지 사용
      return Image.asset(
        '../assets/theft_default.png', // 에셋 경로는 실제 프로젝트에 맞게 조정
        width: width,
        height: height,
        fit: fit,
      );
    }

    try {
      return Image.memory(
        base64Decode(getBase64String(thumbnail!)),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          // 이미지 로드 오류 시 에셋 이미지 사용
          return Image.asset(
            'assets/images/theft_default.png', // 에셋 경로는 실제 프로젝트에 맞게 조정
            width: width,
            height: height,
            fit: fit,
          );
        },
      );
    } catch (e) {
      // 예외 발생 시 에셋 이미지 사용
      return Image.asset(
        'assets/images/theft_default.png', // 에셋 경로는 실제 프로젝트에 맞게 조정
        width: width,
        height: height,
        fit: fit,
      );
    }
  }

  // 제품 이미지를 반환하는 메서드
  Widget getProductImage(String productName,
      {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (!stolenItemImages.containsKey(productName) ||
        stolenItemImages[productName]!.isEmpty) {
      return Icon(Icons.inventory_2, size: width ?? 50);
    }

    try {
      return Image.memory(
        base64Decode(getBase64String(stolenItemImages[productName]!)),
        width: width,
        height: height,
        fit: fit,
      );
    } catch (e) {
      return Icon(Icons.inventory_2, size: width ?? 50);
    }
  }

  // BASE64 문자열에서 접두사 제거
  String getBase64String(String input) {
    // Base64 유효성 검사 및 정화
    // 유효한 Base64 문자만 포함하도록 필터링 (A-Z, a-z, 0-9, +, /, =)
    String cleaned = input.replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '');

    // 유효한 Base64 문자열 길이는 4의 배수여야 함
    // 필요한 경우 패딩 추가
    while (cleaned.length % 4 != 0) {
      cleaned += '=';
    }

    // 특수한 경우: 문자열이 너무 짧으면 기본 빈 Base64 반환
    if (cleaned.length < 4) {
      return '';
    }

    return cleaned;
  }
}
