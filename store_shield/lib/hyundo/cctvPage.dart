import 'package:flutter/material.dart';

class CctvPage extends StatefulWidget {
  const CctvPage({super.key});

  @override
  State<CctvPage> createState() => _CctvPageState();
}

class _CctvPageState extends State<CctvPage> {
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
        title: const Text('cctv 페이지'),
      ),
      body: const Center(
        child: Text(
          '현도가 구현할 cctv페이지지',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
