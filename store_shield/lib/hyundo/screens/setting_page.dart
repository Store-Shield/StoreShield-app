import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../hyechang/custom_bottom_navigation_bar.dart';
import '../../fontstyle.dart';
import '../../hyechang/alertPage.dart';
import '../../socket_service.dart';

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
  int? inventoryThreshold;
  final TextEditingController _thresholdController = TextEditingController();
  bool _isConnected = false;
  final _socketService = SocketService();
  bool _mounted = true; // 위젯 마운트 상태 추적

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
    _socketService.init(); // 소켓 서비스 초기화

    // 소켓 연결 상태 리스너 추가
    _socketService.addConnectionStateListener(_handleConnectionState);

    // 이벤트 리스너 설정
    _setupSocketListeners();
  }

  void _handleConnectionState(bool connected) {
    if (!_mounted) return;

    setState(() {
      _isConnected = connected;
    });

    if (connected) {
      _socketService.emit('get_inventory_threshold');
    }
  }

  @override
  void dispose() {
    _mounted = false; // 마운트 해제 표시
    _thresholdController.dispose();

    // 이벤트 리스너 및 연결 상태 리스너 제거
    _socketService.off('inventory_threshold_response');
    _socketService.removeConnectionStateListener(_handleConnectionState);

    super.dispose();
  }

  void _setupSocketListeners() {
    // 임계값 응답 리스너
    _socketService.on('inventory_threshold_response', (data) {
      if (!_mounted) return;

      setState(() {
        inventoryThreshold = data['threshold'];
        _thresholdController.text = inventoryThreshold.toString();
      });
    });
  }

  void _updateThresholdToServer(int value) {
    if (_isConnected) {
      _socketService.emit('set_inventory_threshold', {'threshold': value});
      debugPrint('서버에 새로운 기준값 전송: $value');
    } else {
      debugPrint('서버 연결 없음 - 값 업데이트 불가');

      // 오프라인 상태일 때 로컬 저장
      _saveThresholdLocally(value);

      // 재연결 시 전송을 위한 이벤트 등록
      _socketService.addConnectionStateListener((connected) {
        if (connected) {
          _socketService.emit('set_inventory_threshold', {'threshold': value});
          // 한 번만 실행하도록 리스너 제거
          _socketService.removeConnectionStateListener((c) {});
        }
      });
    }
  }

  Future<void> _saveThresholdLocally(int value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('inventory_threshold', value);
      debugPrint('임계값이 로컬에 저장되었습니다: $value');
    } catch (e) {
      debugPrint('임계값 로컬 저장 중 오류 발생: $e');
    }
  }

  Future<void> _loadThresholdLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localThreshold = prefs.getInt('inventory_threshold');
      if (localThreshold != null && _mounted) {
        setState(() {
          inventoryThreshold = localThreshold;
          _thresholdController.text = localThreshold.toString();
        });
        debugPrint('로컬에서 임계값 불러옴: $localThreshold');
      }
    } catch (e) {
      debugPrint('임계값 로컬 불러오기 중 오류 발생: $e');
    }
  }

  Future<void> _saveNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', alarmEnabled);
      debugPrint('알림 설정 상태가 ${alarmEnabled ? '활성화' : '비활성화'}되었습니다.');
    } catch (e) {
      debugPrint('알림 설정 저장 중 오류 발생: $e');
    }
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_mounted) {
        setState(() {
          alarmEnabled = prefs.getBool('notifications_enabled') ?? false;
        });
      }
      debugPrint('저장된 알림 설정을 불러왔습니다: ${alarmEnabled ? '활성화' : '비활성화'}');

      // 로컬에서 임계값도 불러오기
      _loadThresholdLocally();
    } catch (e) {
      debugPrint('알림 설정 불러오기 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: StoreText(
                '설정',
                fontSize: screenWidth * 0.07,
              ),
              centerTitle: true,
              backgroundColor: backgroundColor,
              elevation: 0,
              floating: true,
              pinned: false,
              snap: true,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: screenWidth * 0.05),
                  child: IconButton(
                    icon: const Icon(
                      Icons.notifications_none, // 종 모양 아이콘
                      size: 30,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      // 알림 페이지로 이동
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              const AlertPage(), // 알림 페이지 위젯
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ];
        },
        body: Column(
          children: [
            SizedBox(height: screenHeight * 0.03),
            Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              height: screenHeight * 0.06,
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
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                        _saveNotificationSettings();
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
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
                    height: screenHeight * 0.06,
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                            showInventoryInput
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.grey[700],
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showInventoryInput)
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.01),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          StoreText(
                            '재고 부족 기준',
                            fontSize: screenWidth * 0.042,
                            fontWeight: FontWeight.normal,
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                      controller: _thresholdController,
                                      textAlign: TextAlign.center,
                                      textInputAction: TextInputAction.done,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.normal),
                                      decoration: const InputDecoration(
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
                                      onSubmitted: (value) {
                                        final parsed = int.tryParse(value);
                                        if (parsed != null && parsed > 0) {
                                          _updateThresholdToServer(parsed);
                                        }
                                      },
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
      ),
      bottomNavigationBar: const StoreShieldNaviBar(currentIndex: 2),
    );
  }
}