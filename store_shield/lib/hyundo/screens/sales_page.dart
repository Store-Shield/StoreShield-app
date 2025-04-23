import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../../hyechang/custom_bottom_navigation_bar.dart';
import '../../hyechang/fontstyle.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '매출 대시보드',
      theme: ThemeData(
        scaffoldBackgroundColor: AppTheme.backgroundColor,
      ),
      home: const SalePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SalePage extends StatefulWidget {
  const SalePage({super.key});

  @override
  State<SalePage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalePage> {
  int selectedPeriodIndex = 0;
  final List<String> periods = ['Daily', 'Monthly', 'Yearly'];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: StoreText(
          '매출', 
          fontSize: screenWidth * 0.05, 
        ),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 매출 현황
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                child: StoreText(
                  '매출 현황',
                  fontSize: screenWidth * 0.05,
                ),
              ),

              // 기간 선택 탭
              // 배경색을 적용할 큰 Container
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
                    // 기간 선택 탭
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
                                          color: selectedPeriodIndex == i ? Colors.pink : Colors.black,
                                          fontWeight: selectedPeriodIndex == i ? FontWeight.bold : FontWeight.normal,
                                          fontSize: screenWidth * 0.04,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 3,
                                      color: selectedPeriodIndex == i ? Colors.pink : Colors.transparent,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const Divider(height: 1, color: Colors.grey),

                    // 매출 총액
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
                      child: StoreText(
                        '₩ 120,231',
                        fontSize: screenWidth * 0.06,
                      ),
                    ),

                    // 그래프
                    Container(
                      height: screenHeight * 0.2,
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      child: LineChartSample(),
                    ),

                    const Divider(height: 1, color: Colors.grey),

                    // 요일
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.01
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StoreText('D-6', fontSize: screenWidth * 0.035),
                          StoreText('D-5', fontSize: screenWidth * 0.035),
                          StoreText('D-4', fontSize: screenWidth * 0.035),
                          StoreText('D-3', fontSize: screenWidth * 0.035),
                          StoreText('D-2', fontSize: screenWidth * 0.035),
                          StoreText('D-1', fontSize: screenWidth * 0.035),
                          StoreText('today', fontSize: screenWidth * 0.035),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.03),
              
              // 매출액 비교 헤더
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: StoreText(
                  '매출액 비교',
                  fontSize: screenWidth * 0.05
                ),
              ),

              // 이번달/지난달
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: screenHeight * 0.025),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StoreText(
                              '이번달',
                              fontSize: screenWidth * 0.045,
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            StoreText(
                              '₩ 120,231',
                              fontSize: screenWidth * 0.05,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: screenHeight * 0.025),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StoreText(
                              '지난달',
                              fontSize: screenWidth * 0.045,
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            StoreText(
                              '₩ 232,540',
                              fontSize: screenWidth * 0.05,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 전월대비 매출
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: screenHeight * 0.02),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: screenHeight * 0.025),
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
                            '- ',
                            fontSize: screenWidth * 0.055,
                            color: Colors.red,
                          ),
                          StoreText(
                            '₩ 170,231',
                            fontSize: screenWidth * 0.05,
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02), // bottom padding
            ],
          ),
        ),
      ),
      bottomNavigationBar: const StoreShieldNaviBar(currentIndex: 1),
    );
  }
}

class LineChartSample extends StatelessWidget {
  LineChartSample({super.key});

  final List<FlSpot> spots = [
    const FlSpot(0, 3),
    const FlSpot(1, 1),
    const FlSpot(2, 4),
    const FlSpot(3, 2),
    const FlSpot(4, 5),
    const FlSpot(5, 1),
    const FlSpot(6, 4),
  ];

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 6,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue[800],
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
