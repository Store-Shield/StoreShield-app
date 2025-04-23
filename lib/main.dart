import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '판매 캘린더',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFFF2F5FD),
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ko', 'KR'),
        const Locale('en', 'US'),
      ],
      locale: const Locale('ko', 'KR'),
      home: SalesCalendarPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SalesCalendarPage extends StatefulWidget {
  @override
  _SalesCalendarPageState createState() => _SalesCalendarPageState();
}

class _SalesCalendarPageState extends State<SalesCalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime(2025, 4, 1);
  DateTime? _selectedDay;

  // 현재 펼쳐진 항목을 추적하는 맵 추가
  Map<int, bool> _expandedItems = {};

  Map<DateTime, List<SalesData>> _salesEvents = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime(2025, 4, 2);
    _focusedDay = DateTime(2025, 4, 1);

    _loadSampleData();
  }

  void _loadSampleData() {
    _salesEvents = {
      DateTime(2025, 4, 2): [
        SalesData(amount: 59000, description: "총 매출"),
        SalesData(amount: 16300, description: "상품A 판매", details: {
          "고객 ID": "245",
          "상품 내역": [
            {"이름": "가나초콜릿 2개", "가격": 3600},
            {"이름": "포카칩 3개", "가격": 6300},
            {"이름": "하리보 2개", "가격": 6400},
          ],
          "시간": "2025-04-02 9:11"
        }),
        SalesData(amount: 24500, description: "상품B 판매", details: {
          "고객 ID": "157",
          "상품 내역": [
            {"이름": "영수증용지 2개", "가격": 12000},
            {"이름": "펜 세트", "가격": 12500},
          ],
          "시간": "2025-04-02 11:25"
        }),
        SalesData(amount: 18200, description: "상품C 판매", details: {
          "고객 ID": "189",
          "상품 내역": [
            {"이름": "노트북 파우치", "가격": 18200},
          ],
          "시간": "2025-04-02 15:40"
        }),
      ],
      DateTime(2025, 4, 5): [
        SalesData(amount: 75000, description: "총 매출"),
        SalesData(amount: 25000, description: "상품A 판매", details: {
          "고객 ID": "321",
          "상품 내역": [
            {"이름": "삼양라면 5개", "가격": 5500},
            {"이름": "우유 2개", "가격": 6000},
            {"이름": "새우깡 3개", "가격": 13500},
          ],
          "시간": "2025-04-05 14:22"
        }),
        SalesData(amount: 30000, description: "상품B 판매", details: {
          "고객 ID": "157",
          "상품 내역": [
            {"이름": "영수증용지 2개", "가격": 12000},
            {"이름": "펜 세트", "가격": 18000},
          ],
          "시간": "2025-04-05 16:45"
        }),
        SalesData(amount: 20000, description: "상품C 판매", details: {
          "고객 ID": "274",
          "상품 내역": [
            {"이름": "키보드", "가격": 20000},
          ],
          "시간": "2025-04-05 18:10"
        }),
      ],
      DateTime(2025, 4, 9): [
        SalesData(amount: 45000, description: "총 매출"),
        SalesData(amount: 15000, description: "상품A 판매", details: {
          "고객 ID": "432",
          "상품 내역": [
            {"이름": "아이스크림 3개", "가격": 6000},
            {"이름": "과자 세트", "가격": 9000},
          ],
          "시간": "2025-04-09 10:30"
        }),
        SalesData(amount: 20000, description: "상품B 판매", details: {
          "고객 ID": "286",
          "상품 내역": [
            {"이름": "음료수 6개", "가격": 12000},
            {"이름": "초콜릿 4개", "가격": 8000},
          ],
          "시간": "2025-04-09 13:15"
        }),
        SalesData(amount: 10000, description: "상품C 판매", details: {
          "고객 ID": "621",
          "상품 내역": [
            {"이름": "헤어 제품", "가격": 10000},
          ],
          "시간": "2025-04-09 15:20"
        }),
      ],
      DateTime(2025, 3, 15): [
        SalesData(amount: 82000, description: "총 매출"),
        SalesData(amount: 32000, description: "상품A 판매", details: {
          "고객 ID": "189",
          "상품 내역": [
            {"이름": "노트북 파우치", "가격": 22000},
            {"이름": "마우스", "가격": 10000},
          ],
          "시간": "2025-03-15 11:05"
        }),
        SalesData(amount: 30000, description: "상품B 판매", details: {
          "고객 ID": "274",
          "상품 내역": [
            {"이름": "키보드", "가격": 30000},
          ],
          "시간": "2025-03-15 15:30"
        }),
        SalesData(amount: 20000, description: "상품C 판매", details: {
          "고객 ID": "512",
          "상품 내역": [
            {"이름": "화장품 세트", "가격": 20000},
          ],
          "시간": "2025-03-15 17:15"
        }),
      ],
      DateTime(2025, 5, 10): [
        SalesData(amount: 67000, description: "총 매출"),
        SalesData(amount: 27000, description: "상품A 판매", details: {
          "고객 ID": "512",
          "상품 내역": [
            {"이름": "화장품 세트", "가격": 27000},
          ],
          "시간": "2025-05-10 09:45"
        }),
        SalesData(amount: 22000, description: "상품B 판매", details: {
          "고객 ID": "348",
          "상품 내역": [
            {"이름": "손크림 2개", "가격": 8000},
            {"이름": "립밤 3개", "가격": 14000},
          ],
          "시간": "2025-05-10 12:20"
        }),
        SalesData(amount: 18000, description: "상품C 판매", details: {
          "고객 ID": "621",
          "상품 내역": [
            {"이름": "헤어 제품", "가격": 18000},
          ],
          "시간": "2025-05-10 17:50"
        }),
      ],
    };
  }

  List<SalesData> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _salesEvents[normalizedDay] ?? [];
  }

  // 항목 펼침/접힘 토글 메서드
  void _toggleItemExpansion(int index) {
    setState(() {
      _expandedItems[index] = !(_expandedItems[index] ?? false);
    });
  }

  // 이전 달로 이동
  void _previousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    });
  }

  // 다음 달로 이동
  void _nextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '매출내역',
          style: TextStyle(
            color: const Color(0xFF16160F),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color(0xFF16160F)),
          onPressed: () {
            // 뒤로가기 기능
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: const Color(0xFF16160F)),
            onPressed: () {
              // 홈 기능
            },
          ),
        ],
      ),
      // 전체 화면을 SingleChildScrollView로 감싸기
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 캘린더 년월 표시 및 이동 버튼
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left,
                        color: const Color(0xFF16160F)),
                    onPressed: _previousMonth,
                  ),
                  Text(
                    '${_focusedDay.year}년 ${_focusedDay.month}월',
                    style: TextStyle(
                      color: const Color(0xFF16160F),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right,
                        color: const Color(0xFF16160F)),
                    onPressed: _nextMonth,
                  ),
                ],
              ),
            ),

            // 요일 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['월', '화', '수', '목', '금', '토', '일']
                    .map((day) => Text(
                          day,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ))
                    .toList(),
              ),
            ),
            SizedBox(height: 8),

            // 캘린더 위젯을 Padding으로 감싸서 상하 여백 추가
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                locale: 'ko_KR',
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  headerMargin: EdgeInsets.only(bottom: 0.0),
                  headerPadding: EdgeInsets.zero,
                  titleTextFormatter: (date, locale) => '',
                  leftChevronVisible: false,
                  rightChevronVisible: false,
                ),
                calendarStyle: CalendarStyle(
                  tablePadding: EdgeInsets.only(top: 25.0, bottom: 15.0),
                  todayDecoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.rectangle,
                  ),
                  todayTextStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 20,
                        offset: Offset(0, 1),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                  selectedTextStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  defaultTextStyle: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  weekendTextStyle: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  markersMaxCount: 1,
                  markersAlignment: Alignment(0, 0.8),
                  markerDecoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  markerSize: 0,
                  cellMargin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  cellPadding: EdgeInsets.zero,
                ),
                daysOfWeekHeight: 0,
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: Colors.transparent,
                    fontSize: 0,
                  ),
                  weekendStyle: TextStyle(
                    color: Colors.transparent,
                    fontSize: 0,
                  ),
                ),
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    // 날짜가 변경되면 펼쳐진 항목 상태 초기화
                    _expandedItems.clear();
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: _getEventsForDay,
                calendarBuilders: CalendarBuilders(
                  // 마커 커스텀 빌더 - 선택되지 않은 날짜만 마커 표시
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty && !isSameDay(_selectedDay, date)) {
                      final salesAmount = (events.first as SalesData).amount;
                      return Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Text(
                          '+${NumberFormat('#,###').format(salesAmount)}원',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF0000A2),
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                    return null;
                  },

                  // 선택된 날짜 커스텀 빌더
                  selectedBuilder: (context, date, _) {
                    final hasEvents = _getEventsForDay(date).isNotEmpty;
                    final salesAmount =
                        hasEvents ? _getEventsForDay(date).first.amount : 0;

                    return Container(
                      width: 54,
                      height: 70,
                      margin: const EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 20,
                            offset: Offset(0, 1),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 5),
                          if (hasEvents)
                            Text(
                              '+${NumberFormat('#,###').format(salesAmount)}원',
                              style: TextStyle(
                                color: const Color(0xFF0000A2),
                                fontSize: 8,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // 매출 내역 섹션
            _buildSalesDataViewNonScrollable(),
          ],
        ),
      ),
    );
  }

  // 스크롤 없는 버전의 매출 내역 위젯
  Widget _buildSalesDataViewNonScrollable() {
    final salesData = _getEventsForDay(_selectedDay!);

    if (salesData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text('선택한 날짜에 매출 데이터가 없습니다.'),
        ),
      );
    }

    // 총 매출은 첫 번째 항목으로 가정
    final totalSales = salesData.first;

    // 나머지 항목은 상세 내역
    final detailedSales = salesData.sublist(1);

    // 선택된 날짜의 요일 가져오기
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[_selectedDay!.weekday - 1];

    return Container(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Text(
            '매출내역',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF16160F),
            ),
          ),
          SizedBox(height: 4),
          Text(
            '${_selectedDay!.year}년 ${_selectedDay!.month}월 ${_selectedDay!.day}일 ${weekday}요일',
            style: TextStyle(
              color: const Color(0x6616160F),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          // 하얀색 컨테이너로 전체 매출 내역 감싸기
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: ShapeDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 총 매출 표시
                Text(
                  '+${NumberFormat('#,###').format(totalSales.amount)}원',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF16160F),
                  ),
                ),
                SizedBox(height: 16),

                // 모든 상세 매출 항목 표시 (동일한 스타일)
                ...List.generate(
                  detailedSales.length,
                  (index) => _buildSalesItemRow(detailedSales[index], index),
                ),
              ],
            ),
          ),
          // 하단에 여유 공간 추가
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSalesItemRow(SalesData salesItem, int index) {
    final details = salesItem.details;
    final isExpanded = _expandedItems[index] ?? false;

    return GestureDetector(
      onTap: () {
        if (details != null) {
          _toggleItemExpansion(index);
        }
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: const Color(0xFFF2F5FD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: details != null && isExpanded
            ? _buildDetailedItem(salesItem)
            : _buildSimpleItem(salesItem),
      ),
    );
  }

  Widget _buildDetailedItem(SalesData salesItem) {
    final details = salesItem.details!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '+${NumberFormat('#,###').format(salesItem.amount)}원',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF16160F),
          ),
        ),
        SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 3,
              height: 91,
              decoration: ShapeDecoration(
                color: const Color(0xFF0000A2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              margin: EdgeInsets.only(right: 8),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '고객 ID : ${details["고객 ID"]}',
                    style: TextStyle(
                      color: const Color(0xFF0000A2),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),

                  // 상품 내역
                  if (details.containsKey("상품 내역")) ...[
                    for (final product in details["상품 내역"])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                product["이름"],
                                style: TextStyle(
                                  color: const Color(0xFF16160F),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              '${NumberFormat('#,###').format(product["가격"])}원',
                              style: TextStyle(
                                color: const Color(0xFF16160F),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],

                  SizedBox(height: 8),
                  // 시간 정보
                  if (details.containsKey("시간"))
                    Text(
                      details["시간"],
                      style: TextStyle(
                        color: const Color(0xFF8C8C8C),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSimpleItem(SalesData salesItem) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 24,
          decoration: ShapeDecoration(
            color: const Color(0xFF0000A2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          margin: EdgeInsets.only(right: 8),
        ),
        Text(
          '+${NumberFormat('#,###').format(salesItem.amount)}원',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF16160F),
          ),
        ),
      ],
    );
  }
}

// 판매 데이터 모델
class SalesData {
  final int amount;
  final String description;
  final Map<String, dynamic>? details;

  SalesData({
    required this.amount,
    required this.description,
    this.details,
  });
}
