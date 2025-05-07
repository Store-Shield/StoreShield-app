import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../hyechang/custom_bottom_navigation_bar.dart';
import '../../fontstyle.dart';
import '../../hyechang/alertPage.dart';
import '../../socket_service.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  int selectedPeriodIndex = 0;
  final List<String> periods = ['Daily', 'Monthly', 'Yearly'];
  static const Color backgroundColor = Color.fromRGBO(242, 245, 253, 1);

  // 데이터 상태 관리
  List<Map<String, dynamic>> dailyData = [];
  List<Map<String, dynamic>> monthlyData = [];
  List<Map<String, dynamic>> yearlyData = [];
  double currentMonthSales = 0;
  double lastMonthSales = 0;
  final _socketService = SocketService();
  bool _mounted = true; // 위젯 마운트 상태 추적
  bool _isConnected = false; // 소켓 연결 상태

  @override
  void initState() {
    super.initState();
    _socketService.init(); // 소켓 서비스 초기화
    _socketService.addConnectionStateListener(_handleConnectionState);
    _setupSocketListeners();
  }

  void _handleConnectionState(bool connected) {
    if (!_mounted) return;

    setState(() {
      _isConnected = connected;
    });

    if (connected) {
      _requestData(); // 연결되면 데이터 요청
    }
  }

  @override
  void dispose() {
    _mounted = false; // 마운트 해제 표시

    // 이벤트 리스너 및 연결 상태 리스너 제거
    _socketService.off('daily_sales_data');
    _socketService.off('monthly_sales_data');
    _socketService.off('yearly_sales_data');
    _socketService.removeConnectionStateListener(_handleConnectionState);

    super.dispose();
  }

  void _setupSocketListeners() {
    _socketService.on('daily_sales_data', (data) {
      if (!_mounted) return;

      setState(() {
        dailyData = List<Map<String, dynamic>>.from(data);
        _calculateMonthlyComparison();
      });
    });

    _socketService.on('monthly_sales_data', (data) {
      if (!_mounted) return;

      setState(() {
        monthlyData = List<Map<String, dynamic>>.from(data);
        _calculateMonthlyComparison();
      });
    });

    _socketService.on('yearly_sales_data', (data) {
      if (!_mounted) return;

      setState(() {
        yearlyData = List<Map<String, dynamic>>.from(data);
        _calculateMonthlyComparison();
      });
    });
  }

  void _requestData() {
    _socketService.emit('request_sales_data', {'period': 'daily'});
    _socketService.emit('request_sales_data', {'period': 'monthly'});
    _socketService.emit('request_sales_data', {'period': 'yearly'});
  }

  void _calculateMonthlyComparison() {
    if (monthlyData.length >= 2) {
      setState(() {
        currentMonthSales = monthlyData[monthlyData.length - 1]['total'] ?? 0;
        lastMonthSales = monthlyData[monthlyData.length - 2]['total'] ?? 0;
      });
    }
  }

  List<FlSpot> _getSpots(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return []; // 빈 데이터 예외 처리
    }
    return data.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        (entry.value['total'] ?? 0).toDouble(),
      );
    }).toList();
  }

  List<String> _getXLabels() {
    final now = DateTime.now();
    if (selectedPeriodIndex == 0) {
      // 최근 7일: 요일(Mon, Tue, ...)로 표시
      return List.generate(7, (index) {
        final date = now.subtract(Duration(days: 6 - index));
        return DateFormat('E').format(date); // 'E'는 요일 약어 반환 (e.g., Mon, Tue)
      });
    } else if (selectedPeriodIndex == 1) {
      // 최근 7개월: 월(MMM)로 표시
      return List.generate(7, (index) {
        final date = DateTime(now.year, now.month - (6 - index));
        return DateFormat('MMM').format(date); // e.g., Jan, Feb
      });
    } else {
      // 최근 7년: 연도 표시
      return List.generate(7, (index) => '${now.year - (6 - index)}');
    }
  }


  double _getMaxYValue(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 100000;
    final maxValue =
        data.map((e) => e['total'] ?? 0).reduce((a, b) => a > b ? a : b);
    return maxValue * 1.2; // 최대값보다 20% 더 큰 스케일
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final currentData = selectedPeriodIndex == 0
        ? dailyData
        : selectedPeriodIndex == 1
            ? monthlyData
            : yearlyData;

    final totalSales =
        currentData.isNotEmpty ? currentData.last['total'] ?? 0 : 0;

    final monthComparison = currentMonthSales - lastMonthSales;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StoreText(
                      '매출',
                      fontSize: screenWidth * 0.07,
                    ),
                  ],
                ),
                centerTitle: true,
                backgroundColor: backgroundColor,
                elevation: 0,
                floating: true,
                pinned: false,
                snap: true,
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
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.01),
                  child: StoreText(
                    '매출 현황',
                    fontSize: screenWidth * 0.05,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(screenWidth * 0.06),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: screenHeight * 0.04,
                        child: Row(
                          children: [
                            for (int i = 0; i < periods.length; i++)
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedPeriodIndex = i;
                                    });
                                  },
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: StoreText(
                                            periods[i],
                                            color: selectedPeriodIndex == i
                                                ? Colors.pink
                                                : Colors.black,
                                            fontWeight: selectedPeriodIndex == i
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            fontSize: screenWidth * 0.04,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 3,
                                        color: selectedPeriodIndex == i
                                            ? Colors.pink
                                            : Colors.transparent,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Colors.grey),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenHeight * 0.02),
                        child: StoreText(
                          '₩ ${NumberFormat('#,###').format(totalSales)}',
                          fontSize: screenWidth * 0.06,
                        ),
                      ),
                      Container(
                        height: screenHeight * 0.2,
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.07),
                        child: currentData.isEmpty
                            ? Center(
                                child: Text(
                                  _isConnected
                                      ? "데이터를 불러오는 중입니다..."
                                      : "서버에 연결할 수 없습니다",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: screenWidth * 0.04,
                                  ),
                                ),
                              )
                            : LineChart(
                                LineChartData(
                                  gridData: const FlGridData(show: false),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40, // 여기서 값을 늘려 간격 확보
                                        getTitlesWidget: (value, meta) {
                                          final labels = _getXLabels();
                                          if (value < 0 || value > 6 || value % 1 != 0) return const SizedBox.shrink();
                                          return SideTitleWidget(
                                            axisSide: meta.axisSide,
                                            space: 15, // 여기서 값을 늘려 간격 확보
                                            child: StoreText(
                                              labels[value.toInt()],
                                              fontSize: MediaQuery.of(context).size.width * 0.035,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(
                                    show: true, // 테두리 활성화
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade300, // 하단 경계선 색상
                                        width: 1, // 선 두께
                                      ),
                                    ),
                                  ),
                                  minX: 0,
                                  maxX: 6,
                                  minY: 0,
                                  maxY: _getMaxYValue(currentData),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: _getSpots(currentData),
                                      isCurved: true,
                                      color: Colors.blue[800],
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: const FlDotData(show: false),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: Colors.blue.withOpacity(0.1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.01),
                  child: StoreText('매출액 비교', fontSize: screenWidth * 0.05),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.06,
                              vertical: screenHeight * 0.025),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StoreText(
                                '이번달',
                                fontSize: screenWidth * 0.045,
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              StoreText(
                                '₩ ${NumberFormat('#,###').format(currentMonthSales)}',
                                fontSize: screenWidth * 0.05,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.06,
                              vertical: screenHeight * 0.025),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StoreText(
                                '지난달',
                                fontSize: screenWidth * 0.045,
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              StoreText(
                                '₩ ${NumberFormat('#,###').format(lastMonthSales)}',
                                fontSize: screenWidth * 0.05,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenHeight * 0.02),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.06,
                        vertical: screenHeight * 0.025),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StoreText(
                          '전월대비 매출액',
                          fontSize: screenWidth * 0.045,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Row(
                          children: [
                            StoreText(
                              monthComparison >= 0 ? '+ ' : '- ',
                              fontSize: screenWidth * 0.055,
                              color: monthComparison >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            StoreText(
                              '₩ ${NumberFormat('#,###').format(monthComparison.abs())}',
                              fontSize: screenWidth * 0.05,
                              color: monthComparison >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const StoreShieldNaviBar(currentIndex: 1),
    );
  }
}