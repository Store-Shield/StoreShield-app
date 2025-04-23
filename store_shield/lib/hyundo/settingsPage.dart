import 'package:flutter/material.dart';
import '../hyechang/custom_bottom_navigation_bar.dart'; // StoreShieldNaviBar가 정의된 파일 import

class Settingspage extends StatefulWidget {
  const Settingspage({super.key});

  @override
  State<Settingspage> createState() => _SettingPageState();
}

class _SettingPageState extends State<Settingspage> {
  @override
  void initState() {
    super.initState();
    // 초기화 코드 작성 위치
  }

  @override
  void dispose() {
    // 정리 코드 작성 위치
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정 페이지'),
      ),
      body: const Center(
        child: Text(
          '현도가 구현한 설정 페이지',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: const StoreShieldNaviBar(currentIndex: 2),
    );
  }
}
