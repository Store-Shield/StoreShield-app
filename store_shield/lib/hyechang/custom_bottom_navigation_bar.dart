import 'package:flutter/material.dart';
import 'package:store_shield/hyundo/screens/sales_page.dart';
import 'package:store_shield/hyundo/screens/setting_page.dart';
import 'package:store_shield/mainPage.dart';

class StoreShieldNaviBar extends StatelessWidget {
  final int currentIndex;

  const StoreShieldNaviBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: '매출',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: '설정',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.blue,
      backgroundColor: Colors.white,
      onTap: (index) {
        // 현재 선택된 인덱스와 다른 경우에만 화면 전환
        if (index != currentIndex) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainPage()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SalesPage()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
              break;
          }
        }
      },
    );
  }
}
