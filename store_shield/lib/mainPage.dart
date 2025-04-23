import 'package:flutter/material.dart';
import 'package:store_shield/hyundo/cctvPage.dart';
import 'package:store_shield/sangwoo/salesHistoryPage.dart';
import 'package:store_shield/sunbin/managementPage.dart';
import 'hyechang/custom_bottom_navigation_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'hyechang/fontstyle.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    //초기화해야할곳
  }

  @override
  void dispose() {
    super.dispose();
    //화면없어질 때 해야할 것
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const StoreText(
          "text",
          fontSize: 40,
          color: Colors.green,
        )),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //오늘의 매장
                Container(
                  width: double.infinity,
                  height:
                      MediaQuery.of(context).size.height * 0.3, // 화면 높이의 30%
                  color: Colors.red,
                  child: const Center(child: Text('오늘의 매장')),
                ),

                ////바로 가기
                Container(
                    width: double.infinity,
                    height:
                        MediaQuery.of(context).size.height * 0.2, // 화면 높이의 20%
                    color: Colors.blue,
                    child: Column(
                      children: [
                        const Text("data"),
                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(50, 40),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const CctvPage(),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                    transitionDuration:
                                        const Duration(milliseconds: 300),
                                  ),
                                );
                              },
                              child: const StoreText('실시간 cctv', fontSize: 15),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(50, 40),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const ManagementPage(),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                    transitionDuration:
                                        const Duration(milliseconds: 300),
                                  ),
                                );
                              },
                              child: const StoreText('재고관리', fontSize: 15),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(50, 40),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const SaleshistoryPage(),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                    transitionDuration:
                                        const Duration(milliseconds: 300),
                                  ),
                                );
                              },
                              child: const StoreText('매출내역', fontSize: 15),
                            ),
                          ],
                        )
                      ],
                    )),

                //인기상품
                Container(
                  width: double.infinity,
                  height:
                      MediaQuery.of(context).size.height * 0.5, // 화면 높이의 30%
                  color: Colors.green,
                  child: const Center(child: Text('인기상품')),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const StoreShieldNaviBar(currentIndex: 0));
  }
}
