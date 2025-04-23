import 'package:flutter/material.dart';
import 'package:store_shield/mainPage.dart';
import '../hyundo/screens/sales_page.dart';
import '../hyundo/screens/setting_Page.dart';

class StoreShieldNaviBar extends StatelessWidget {
  final int currentIndex;

  const StoreShieldNaviBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: BottomNavigationBar(
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
        backgroundColor: Colors.white, // ✅ 배경색 흰색
        onTap: (index) {
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
                  MaterialPageRoute(builder: (context) => const SettingPage()),
                );
                break;
            }
          }
        },
      ),
    );
  }
}
