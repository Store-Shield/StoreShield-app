import 'package:flutter/material.dart';

class ManagementPage extends StatefulWidget {
  const ManagementPage({super.key});

  @override
  State<ManagementPage> createState() => _ManagementPageState();
}

class _ManagementPageState extends State<ManagementPage> {
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
        title: const Text('재고관리  페이지'),
      ),
      body: const Center(
        child: Text(
          '선빈이가  구현할 재고관리페이지',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
