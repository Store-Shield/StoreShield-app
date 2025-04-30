import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../hyechang/fontstyle.dart';
import 'dart:async';
import '../hyundo/socket_service.dart'; // SocketService import 추가

class SaleshistoryPage extends StatelessWidget {
  const SaleshistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SalesCalendarPage();
  }
}

class SalesCalendarPage extends StatefulWidget {
  const SalesCalendarPage({super.key});

  @override
  _SalesCalendarPageState createState() => _SalesCalendarPageState();
}

class _SalesCalendarPageState extends State<SalesCalendarPage> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<int, bool> _expandedItems = {};
  Map<DateTime, List<SalesData>> _salesEvents = {};
  bool _isLoading = false;
  bool _isLoadingDetails = false;
  String? _errorMessage;
  final Set<String> _loadedDetailDates = {};
  static const Color backgroundColor = Color.fromRGBO(242, 245, 253, 1);

  // SocketService 인스턴스 사용
  final _socketService = SocketService();
  bool _mounted = true;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();

    // 소켓 연결 상태 리스너 등록
    _socketService.init(); // 소켓 서비스 명시적 초기화 추가
    _socketService.addConnectionStateListener(_handleConnectionState);
    _setupSocketListeners();

    // 중요: 이미 연결되어 있을 때와 아닐 때를 분리하여 처리
    if (_socketService.isConnected) {
      // 이미 연결되어 있으면 바로 데이터 요청
      _loadSalesData(_focusedDay.year, _focusedDay.month);
    }
    // 연결되어 있지 않다면 handleConnectionState에서 데이터를 요청할 것임
  }

  void _handleConnectionState(bool connected) {
    if (!_mounted) return;

    setState(() {
      _isConnected = connected;
    });

    if (connected) {
      // 최초 연결 또는 재연결 시에만 데이터 요청
      if (_errorMessage != null || _salesEvents.isEmpty) {
        _loadSalesData(_focusedDay.year, _focusedDay.month);
      }
    } else {
      setState(() {
        _errorMessage = '서버 연결이 끊어졌습니다. 재연결 중...';
      });
    }
  }

  void _setupSocketListeners() {
    _socketService.on('monthly_sales_result', _handleMonthlySalesData);
    _socketService.on('daily_sales_result', _handleDailySalesData);
  }

  Future<void> _loadSalesData(int year, int month) async {
    if (!_isConnected) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _socketService.emit('salesPageload', {
        'pageType': 'monthlySales',
        'year': year,
        'month': month
      });
      print('월별 매출 데이터 요청: $year년 $month월');
    } catch (e) {
      setState(() {
        _errorMessage = '오류: $e';
        _isLoading = false;
      });
      print('데이터 요청 중 오류 발생: $e');
    }
  }

  void _handleMonthlySalesData(dynamic data) {
    if (!_mounted) return;

    try {
      if (data is Map) {
        final Map<DateTime, List<SalesData>> events = {};

        data.forEach((dateStr, value) {
          if (value is Map && dateStr is String) {
            final date = DateTime.parse(dateStr);
            final totalAmount = value['total'] ?? 0;
            events[date] = [
              SalesData(amount: totalAmount.toDouble(), description: "총 매출")
            ];
          }
        });

        setState(() {
          _salesEvents = events;
          _isLoading = false;
          if (_selectedDay != null) _loadDailyDetails(_selectedDay!);
        });
      } else if (data is Map && data.containsKey('error')) {
        setState(() {
          _errorMessage = '서버 오류: ${data['error']}';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = '잘못된 데이터 형식';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '데이터 처리 오류: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDailyDetails(DateTime day) async {
    if (!_isConnected) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(day);
    if (_loadedDetailDates.contains(dateStr)) return;

    setState(() {
      _isLoadingDetails = true;
    });

    try {
      _socketService.emit('salesPageload', {
        'pageType': 'dailySales',
        'date': dateStr
      });
    } catch (e) {
      setState(() {
        _isLoadingDetails = false;
      });
    }
  }

  void _handleDailySalesData(dynamic data) {
    if (!_mounted || _selectedDay == null) return;

    try {
      if (data is Map) {
        final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDay!);
        final normalizedDay = DateTime(
            _selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
        final existingEvents = _salesEvents[normalizedDay] ?? [];
        final List<SalesData> detailedSales = [];

        // 총액 항목 유지
        if (existingEvents.isNotEmpty) {
          detailedSales.add(existingEvents.first);
        } else {
          detailedSales.add(SalesData(
              amount: data['total']?.toDouble() ?? 0.0, description: "총 매출"));
        }

        // 상세 항목 추가
        if (data.containsKey('items') && data['items'] is List) {
          for (var item in data['items'] as List<dynamic>) {
            if (item is Map) {
              detailedSales.add(SalesData(
                  amount: (item['amount'] ?? 0).toDouble(),
                  description: item['description'] ?? "알 수 없는 상품",
                  details: item['details']));
            }
          }
        }

        setState(() {
          _salesEvents[normalizedDay] = detailedSales;
          _isLoadingDetails = false;
          _loadedDetailDates.add(dateStr);
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingDetails = false;
      });
    }
  }

  @override
  void dispose() {
    _mounted = false;
    // 리스너만 제거하고 소켓 연결은 유지
    _socketService.off('monthly_sales_result', _handleMonthlySalesData);
    _socketService.off('daily_sales_result', _handleDailySalesData);
    _socketService.removeConnectionStateListener(_handleConnectionState);
    super.dispose();
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
    // 월이 변경되면 새 데이터 로드
    _loadSalesData(_focusedDay.year, _focusedDay.month);
  }

  // 다음 달로 이동
  void _nextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    });
    // 월이 변경되면 새 데이터 로드
    _loadSalesData(_focusedDay.year, _focusedDay.month);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const StoreText(
          '매출내역',
          fontSize: 30,
          color: Color(0xFF16160F),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF16160F)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Color(0xFF16160F)),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: StoreText('오류: $_errorMessage', color: Colors.red))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // 캘린더 년월 표시 및 이동 버튼
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left,
                                  color: Color(0xFF16160F)),
                              onPressed: _previousMonth,
                            ),
                            StoreText(
                              '${_focusedDay.year}년 ${_focusedDay.month}월',
                              fontSize: 18,
                              color: const Color(0xFF16160F),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right,
                                  color: Color(0xFF16160F)),
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
                              .map((day) => StoreText(
                                    day,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 캘린더 위젯
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
                            headerMargin: const EdgeInsets.only(bottom: 0.0),
                            headerPadding: EdgeInsets.zero,
                            titleTextFormatter: (date, locale) => '',
                            leftChevronVisible: false,
                            rightChevronVisible: false,
                          ),
                          calendarStyle: CalendarStyle(
                            tablePadding:
                                const EdgeInsets.only(top: 25.0, bottom: 15.0),
                            todayDecoration: const BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.rectangle,
                            ),
                            todayTextStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 1),
                                  spreadRadius: 0,
                                )
                              ],
                            ),
                            selectedTextStyle: const TextStyle(
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
                            markersAlignment: const Alignment(0, 0.8),
                            markerDecoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                            markerSize: 0,
                            cellMargin: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 4),
                            cellPadding: EdgeInsets.zero,
                          ),
                          daysOfWeekHeight: 0,
                          daysOfWeekStyle: const DaysOfWeekStyle(
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

                            // 선택한 날짜의 상세 정보 로드
                            _loadDailyDetails(selectedDay);
                          },
                          onPageChanged: (focusedDay) {
                            setState(() {
                              _focusedDay = focusedDay;
                            });
                            // 페이지 변경 시 새 데이터 로드
                            _loadSalesData(focusedDay.year, focusedDay.month);
                          },
                          eventLoader: _getEventsForDay,
                          calendarBuilders: CalendarBuilders(
                            // 마커 커스텀 빌더 - 선택되지 않은 날짜만 마커 표시
                            markerBuilder: (context, date, events) {
                              if (events.isNotEmpty &&
                                  !isSameDay(_selectedDay, date)) {
                                final salesAmount =
                                    (events.first as SalesData).amount;
                                return Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Text(
                                    '+${NumberFormat('#,###').format(salesAmount)}원',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFF0000A2),
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
                              final hasEvents =
                                  _getEventsForDay(date).isNotEmpty;
                              final salesAmount = hasEvents
                                  ? _getEventsForDay(date).first.amount
                                  : 0;

                              return Container(
                                width: 54,
                                height: 70,
                                margin: const EdgeInsets.only(bottom: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: const [
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
                                    StoreText(
                                      '${date.day}',
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(height: 5),
                                    if (hasEvents)
                                      Text(
                                        '+${NumberFormat('#,###').format(salesAmount)}원',
                                        style: const TextStyle(
                                          color: Color(0xFF0000A2),
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
    final salesData =
        _selectedDay != null ? _getEventsForDay(_selectedDay!) : [];

    // 상세 정보 로딩 중
    if (_isLoadingDetails) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (salesData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: StoreText('선택한 날짜에 매출 데이터가 없습니다.'),
        ),
      );
    }

    // 총 매출은 첫 번째 항목으로 가정
    final totalSales = salesData.first;

    // 나머지 항목은 상세 내역
    final detailedSales = salesData.length > 1 ? salesData.sublist(1) : [];

    // 선택된 날짜의 요일 가져오기
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[_selectedDay!.weekday - 1];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const StoreText(
            '매출내역',
            fontSize: 20,
            color: Color(0xFF16160F),
          ),
          const SizedBox(height: 4),
          StoreText(
            '${_selectedDay!.year}년 ${_selectedDay!.month}월 ${_selectedDay!.day}일 $weekday요일',
            fontSize: 10,
            color: const Color(0x6616160F),
          ),
          const SizedBox(height: 8),
          // 하얀색 컨테이너로 전체 매출 내역 감싸기
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
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
                StoreText(
                  '+${NumberFormat('#,###').format(totalSales.amount)}원',
                  fontSize: 26,
                  color: const Color(0xFF16160F),
                ),
                const SizedBox(height: 16),

                // 모든 상세 매출 항목 표시 (동일한 스타일)
                ...List.generate(
                  detailedSales.length,
                  (index) => _buildSalesItemRow(detailedSales[index], index),
                ),
              ],
            ),
          ),
          // 하단에 여유 공간 추가
          const SizedBox(height: 40),
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
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: const ShapeDecoration(
          color: Color(0xFFF2F5FD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
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
        StoreText(
          '+${NumberFormat('#,###').format(salesItem.amount)}원',
          fontSize: 22,
          color: const Color(0xFF16160F),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 3,
              height: 91,
              decoration: const ShapeDecoration(
                color: Color(0xFF0000A2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
              margin: const EdgeInsets.only(right: 8),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StoreText(
                    '고객 ID : ${details["고객 ID"]}',
                    fontSize: 10,
                    color: const Color(0xFF0000A2),
                  ),
                  const SizedBox(height: 8),

                  // 상품 내역
                  if (details.containsKey("상품 내역")) ...[
                    for (final product in details["상품 내역"])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: StoreText(
                                product["이름"],
                                fontSize: 10,
                                color: const Color(0xFF16160F),
                              ),
                            ),
                            StoreText(
                              '${NumberFormat('#,###').format(product["가격"])}원',
                              fontSize: 10,
                              color: const Color(0xFF16160F),
                            ),
                          ],
                        ),
                      ),
                  ],

                  const SizedBox(height: 8),
                  // 시간 정보
                  if (details.containsKey("시간"))
                    StoreText(
                      details["시간"],
                      fontSize: 12,
                      color: const Color(0xFF8C8C8C),
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
          decoration: const ShapeDecoration(
            color: Color(0xFF0000A2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
          ),
          margin: const EdgeInsets.only(right: 8),
        ),
        StoreText(
          '+${NumberFormat('#,###').format(salesItem.amount)}원',
          fontSize: 18,
          color: const Color(0xFF16160F),
        ),
      ],
    );
  }
}

// 판매 데이터 모델
class SalesData {
  final double amount;
  final String description;
  final Map<String, dynamic>? details;

  SalesData({
    required this.amount,
    required this.description,
    this.details,
  });
}
