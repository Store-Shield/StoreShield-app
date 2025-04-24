import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'model/stock_alert_data.dart';
import 'model/event.dart';
import 'model/suspectorData.dart';
import 'widget/suspect_item.dart';
import 'widget/stock_alert_item.dart';
import 'widget/calendar_widget.dart';
import 'fontstyle.dart';
import 'hyechang_socket.dart';
import '../socketURL.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage>
    with SingleTickerProviderStateMixin {
  // 소켓 서비스
  final SocketService socketService = SocketService();

  // 탭 컨트롤러
  late TabController _tabController;

  // 날짜 관련
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // 데이터 관련
  bool isLoading = true;
  Map<DateTime, List<SuspectData>> suspectsByDate = {};
  List<StockAlertData> stockAlerts = [];

  // 달력에 표시할 이벤트 마커
  Map<DateTime, List<Event>> events = {};

  // 캘린더 표시 여부
  bool showCalendar = false;

  // 서버 연결 상태
  bool isConnected = false;

  // 에러 메시지
  String errorMessage = '';

  static const Color backgroundColor = Color.fromRGBO(242, 245, 253, 1);

  bool calLoadding = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 소켓 연결 및 데이터 로드
    _connectAndLoadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 소켓 연결 및 초기 데이터 로드
  Future<void> _connectAndLoadData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // 소켓 연결
      await socketService.initSocket(SocketConfig.socketURL);
      isConnected = true;

      // 데이터 로드
      await _loadData();
    } catch (e) {
      setState(() {
        isConnected = false;
        errorMessage = '서버 연결 오류: $e';
        isLoading = false;
      });
      print('소켓 연결 오류: $e');
    }
  }

  // 데이터 로드 함수
  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 현재 연도 기준으로 데이터 로드
      await _loadYearData(_focusedDay.year);

      // 재고 알림 데이터 로드
      await _loadStockAlerts();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('데이터 로드 오류: $e');
      setState(() {
        errorMessage = '데이터 로드 오류: $e';
        isLoading = false;
      });
    }
  }

  // 연도별 용의자 데이터 로드
  Future<void> _loadYearData(int year) async {
    try {
      // 로딩 인디케이터 표시 (필요에 따라 사용)
      // setState(() { isLoading = true; });

      // 서버에 연도별 용의자 데이터 요청
      final suspectData = await socketService.getYearSuspectData(year);

      // suspectsByDate 및 events 초기화
      final Map<DateTime, List<SuspectData>> newSuspectsByDate = {};
      final Map<DateTime, List<Event>> newEvents = {};

      print('로드된 데이터: ${suspectData.length} 항목');
      print('생성된 이벤트 개수: ${newEvents.length}');
      print(
          '이벤트 날짜: ${newEvents.keys.map((date) => DateFormat('yyyy-MM-dd').format(date)).toList()}');

      // 수신한 데이터를 가공하여 저장
      for (final data in suspectData) {
        try {
          // 용의자 데이터 파싱
          final id = data['customer_id'] ?? 0;
          final comeInStr = data['come_in'] ?? '';
          final comeOutStr = data['come_out'] ?? '';
          final calState = data['cal_state'] ?? '';
          final customerImage = data['customer_image'] ?? '';
          final videoThumbnail = data['video_thumbnail'] ?? '';

          // DateTime 변환
          final comeIn = DateTime.parse(comeInStr);
          final comeOut = DateTime.parse(comeOutStr);

          // 날짜 키 생성 (년,월,일만 사용)
          final dateKey = DateTime(comeIn.year, comeIn.month, comeIn.day);

          // 도난 물품 및 이미지 파싱
          final Map<String, int> stolenItems = {};
          final Map<String, String> stolenItemImages = {};

          if (data.containsKey('stolen_items')) {
            final items = data['stolen_items'];
            items.forEach((key, value) {
              stolenItems[key.toString()] = value as int;
            });
          }

          if (data.containsKey('stolen_item_images')) {
            final images = data['stolen_item_images'];
            images.forEach((key, value) {
              stolenItemImages[key.toString()] = value.toString();
            });
          }

          // SuspectData 객체 생성
          final suspect = SuspectData(
            id: id,
            comeIn: comeIn,
            comeOut: comeOut,
            calState: calState,
            customerImage: customerImage,
            stolenItems: stolenItems,
            stolenItemImages: stolenItemImages,
            thumbnail: videoThumbnail,
          );

          // 날짜별 용의자 목록에 추가
          if (newSuspectsByDate.containsKey(dateKey)) {
            newSuspectsByDate[dateKey]!.add(suspect);
          } else {
            newSuspectsByDate[dateKey] = [suspect];
          }

          // 이벤트 마커 추가
          newEvents[dateKey] = [Event('도난 의심')];
        } catch (e) {
          print('용의자 데이터 파싱 오류: $e');
        }
      }

      setState(() {
        suspectsByDate = newSuspectsByDate;
        events = newEvents;
      });

      print('$year년 용의자 데이터 로드 완료: ${newSuspectsByDate.length}일의 데이터');
    } catch (e) {
      print('연도별 용의자 데이터 로드 오류: $e');
      rethrow;
    }
  }

  // 재고 알림 데이터 로드
  Future<void> _loadStockAlerts() async {
    try {
      // 알림 페이지 데이터 요청 (재고 부족 기준 5개)
      final result = await socketService.getAlertPageData();
      final stockData = result['stock_data'];

      // 재고 알림 목록 초기화
      final List<StockAlertData> newStockAlerts = [];

      // 수신한 데이터 파싱
      for (final data in stockData) {
        try {
          final id = data['id'] ?? 0;
          final productName = data['product_name'] ?? '';
          final currentStock = data['product_stock'] ?? 0;
          final minStock = data['min_stock'] ?? 5;
          final productImage = data['product_image'] ?? '';

          // StockAlertData 객체 생성
          final stockAlert = StockAlertData(
            id: id,
            productName: productName,
            currentStock: currentStock,
            minStock: minStock,
            productImage: productImage,
          );

          newStockAlerts.add(stockAlert);
        } catch (e) {
          print('재고 알림 데이터 파싱 오류: $e');
        }
      }

      setState(() {
        stockAlerts = newStockAlerts;
      });

      print('재고 알림 데이터 로드 완료: ${newStockAlerts.length}개 항목');
    } catch (e) {
      print('재고 알림 데이터 로드 오류: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight), // 앱바만의 높이
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            title: StoreText(
              '알림',
              fontSize: screenWidth * 0.05,
            ),
            centerTitle: true,
            backgroundColor: Colors.white, // 배경색 고정
            elevation: 0,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      StoreText(
                        errorMessage,
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _connectAndLoadData,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // 투명한 배경의 TabBar 직접 구현
                    Container(
                      child: TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: '절도 용의자'),
                          Tab(text: '재고 알림'),
                        ],
                        labelColor: Colors.blue,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.blue,
                        // 투명 배경 설정
                        indicatorSize: TabBarIndicatorSize.label,
                        // TabBar 배경색 제거
                        indicator: const UnderlineTabIndicator(
                          borderSide:
                              BorderSide(width: 2.0, color: Colors.blue),
                        ),
                      ),
                    ),

                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // 절도 용의자 탭
                          _buildSuspectsTab(),

                          // 재고 알림 탭
                          _buildStockAlertsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // 절도 용의자 탭 위젯
  Widget _buildSuspectsTab() {
    final suspects = suspectsByDate.entries
        .where((entry) => isSameDay(entry.key, _selectedDay))
        .expand((entry) => entry.value)
        .toList();

    return Column(
      children: [
        // 날짜 선택 헤더
        InkWell(
          onTap: () {
            setState(() {
              showCalendar = !showCalendar;
            });
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 30, 10, 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StoreText(
                  "절도 용의자",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    StoreText(
                      DateFormat('yyyy.MM.dd').format(_selectedDay),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      showCalendar
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // 캘린더 표시
        if (showCalendar)
          Column(
            children: [
              isLoading && events.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              calLoadding
                  ? const Padding(
                      padding: EdgeInsets.fromLTRB(8.0, 20, 8, 0),
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 8,
                          ),
                        ),
                      ),
                    )
                  : CalendarWidget(
                      selectedDay: _selectedDay,
                      focusedDay: _focusedDay,
                      events: events,
                      onDaySelected: (selectedDay, focusedDay) async {
                        // 선택 날짜 갱신
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          showCalendar = false; // 날짜 선택 후 캘린더 닫기
                        });
                      },
                      // 페이지 변경 시 콜백 (월 변경)
                      onPageChanged: (focusedDay) {
                        // 월이 바뀌어도 연도가 바뀌는 경우 데이터 새로 로드
                        if (focusedDay.year != _focusedDay.year) {
                          // 비동기로 데이터 로드 (화면 전환 막지 않기 위해)
                          setState(() {
                            calLoadding = true;
                          });

                          _loadYearData(focusedDay.year).then((_) {
                            // 성공 시 focusedDay 갱신
                            setState(() {
                              _focusedDay = focusedDay;
                              calLoadding = false;
                              isLoading = false;
                            });
                          }).catchError((e) {
                            // 오류 시 메시지 표시
                            print('연도 변경 데이터 로드 오류: $e');
                          });
                        } else {
                          // 같은 연도 내 월 변경만 있는 경우
                          setState(() {
                            _focusedDay = focusedDay;
                          });
                        }
                      },
                    )
            ],
          ),

        // 용의자 목록
        Expanded(
          child: suspects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      StoreText(
                        '해당 날짜에 용의자가 없습니다',
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: suspects.length,
                  itemBuilder: (context, index) {
                    return SuspectItem(suspect: suspects[index]);
                  },
                ),
        ),
      ],
    );
  }

  // 재고 알림 탭 위젯
  Widget _buildStockAlertsTab() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 30, 10, 20),
      color: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StoreText(
            '재고 알림',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
          Expanded(
            child: stockAlerts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        StoreText(
                          '재고 알림이 없습니다',
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: stockAlerts.length,
                    itemBuilder: (context, index) {
                      return StockAlertItem(stockAlert: stockAlerts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
