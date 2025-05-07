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
          // 방향 결정: 현재 인덱스보다 선택한 인덱스가 크면 오른쪽으로, 작으면 왼쪽으로
          final bool toRight = index > currentIndex;
          
          Widget page;
          switch (index) {
            case 0:
              page = const MainPage();
              break;
            case 1:
              page = const SalesPage();
              break;
            case 2:
              page = const SettingsPage();
              break;
            default:
              page = const MainPage();
          }
          
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => page,
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0); // 기본 시작점 (오른쪽)
                const end = Offset.zero;
                
                // 왼쪽으로 이동해야 하는 경우
                final Offset startOffset = toRight ? begin : Offset(-1.0, 0.0);
                
                final tween = Tween(begin: startOffset, end: end);
                final offsetAnimation = animation.drive(tween);
                
                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 100),
            ),
          );
        }
      },
    );
  }
}