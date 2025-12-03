import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../hyechang/custom_bottom_navigation_bar.dart';
import '../../hyechang/fontstyle.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Settings Page',
      home: const SettingsPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool alarmEnabled = false;
  bool inventoryThresholdEnabled = true;
  bool showInventoryInput = false;
  static const Color backgroundColor = Color.fromRGBO(242, 245, 253, 1);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: StoreText(
          '설정',
          fontSize: screenWidth * 0.05,
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: screenWidth * 0.05),
            child: Image.asset(
              'lib/hyundo/assets/notificationIcon.png',
              width: screenWidth * 0.055,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.03),
          // Alarm Setting Card
          Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            height: screenHeight * 0.06, // 고정된 높이 설정
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center, // 세로 중앙 정렬
                    children: [
                      Image.asset(
                        'lib/hyundo/assets/alarmIcon.png',
                        width: screenWidth * 0.04,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      StoreText(
                        '알림',
                        fontSize: screenWidth * 0.042,
                        fontWeight: FontWeight.normal,
                      ),
                    ],
                  ),
                  CupertinoSwitch(
                    value: alarmEnabled,
                    onChanged: (value) {
                      setState(() {
                        alarmEnabled = value;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: screenHeight * 0.015),

          // Inventory Settings Card
          Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: screenHeight * 0.06, // 알림 설정 카드와 동일한 높이
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center, // 세로 중앙 정렬
                    children: [
                      Image.asset(
                        'lib/hyundo/assets/stockIcon.png',
                        width: screenWidth * 0.045,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      StoreText(
                        '재고 부족 개수 설정',
                        fontSize: screenWidth * 0.042,
                        fontWeight: FontWeight.normal,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showInventoryInput = !showInventoryInput;
                          });
                        },
                        child: Icon(
                          showInventoryInput ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.grey[700],
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),

                if (showInventoryInput)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center, // 세로 중앙 정렬
                      children: [
                        StoreText(
                          '재고 부족 기준',
                          fontSize: screenWidth * 0.042,
                          fontWeight: FontWeight.normal,
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center, // 세로 중앙 정렬
                            children: [
                              Container(
                                height: screenHeight * 0.03,
                                decoration: BoxDecoration(
                                  color: Colors.blue[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                width: screenWidth * 0.15,
                                child: Center(
                                  child: TextField(
                                    textAlign: TextAlign.center,
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.number, // 숫자 키패드
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.normal
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                    ),
                                    maxLines: 1,
                                    textAlignVertical: TextAlignVertical.center,
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.01),
                              StoreText(
                                '개 이하',
                                fontSize: screenWidth * 0.042,
                                fontWeight: FontWeight.normal,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: showInventoryInput ? screenHeight * 0.01 : 0),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
      bottomNavigationBar: const StoreShieldNaviBar(currentIndex: 2),
    );
  }
}