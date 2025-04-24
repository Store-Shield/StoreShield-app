import 'dart:convert';
import 'package:flutter/material.dart';

class StockAlertData {
  final int id;
  final String productName; // 제품 이름
  final int currentStock; // 현재 재고
  final int minStock; // 최소 재고 기준
  final String? productImage; // 제품 이미지 BASE64 문자열

  StockAlertData({
    required this.id,
    required this.productName,
    required this.currentStock,
    required this.minStock,
    this.productImage,
  });

  // BASE64 이미지를 디코딩하여 Image 위젯 반환
  Widget getImage({double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (productImage == null || productImage!.isEmpty) {
      return Icon(Icons.inventory_2, size: width ?? 60);
    }

    try {
      return Image.memory(
        base64Decode(getBase64String(productImage!)),
        width: width,
        height: height,
        fit: fit,
      );
    } catch (e) {
      return Icon(Icons.inventory_2, size: width ?? 60);
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
