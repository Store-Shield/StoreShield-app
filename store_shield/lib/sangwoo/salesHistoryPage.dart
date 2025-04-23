import 'package:flutter/material.dart';

class SaleshistoryPage extends StatefulWidget {
  const SaleshistoryPage({super.key});

  @override
  State<SaleshistoryPage> createState() => _SaleshistoryPageState();
}

class _SaleshistoryPageState extends State<SaleshistoryPage> {
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
        title: const Text('매출내역 페이지'),
      ),
      body: const Center(
        child: Text(
          '상우가 구현할 매출내역페이지',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
