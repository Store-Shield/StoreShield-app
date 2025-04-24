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
  String getBase64String(String base64String) {
    if (base64String.contains(',')) {
      return base64String.split(',')[1];
    }
    return base64String;
  }
}
