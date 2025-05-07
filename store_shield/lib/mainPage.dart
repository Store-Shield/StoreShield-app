import 'package:flutter/material.dart';
import 'package:store_shield/hyundo/screens/cctv_page.dart';
import 'package:store_shield/sangwoo/salesHistoryPage.dart';
import 'package:store_shield/sunbin_pages/managementPage/management_page.dart';
import 'hyechang/custom_bottom_navigation_bar.dart';
import 'package:intl/intl.dart';
import 'fontstyle.dart';
import 'socketURL.dart';
import './hyechang/hyechang_socket.dart';
import 'package:store_shield/hyechang/alertPage.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final SocketService socketService = SocketService();
  static const Color backgroundColor = Color.fromRGBO(242, 245, 253, 1);

  late DateTime now;
  late String formattedDate;

  // 데이터 변수
  int customerCount = 0; // 일일 고객 수
  int suspiciousCount = 0; // 일일 도난 의심
  double dailySales = 0.0; // 일일 매출액

  // 로딩 상태 변수
  bool isLoading = true;
  String errorMessage = '';

  // 일,월,년 구분변수
  int type = 1; // 1=일 2=월 3=년
  // 기간별 인기 상품 데이터
  Map<int, List<ProductSale>> periodProducts = {
    1: [], // 일별 데이터
    2: [], // 월별 데이터
    3: [], // 년별 데이터
  };

  // 통화 포맷 함수
  String formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'ko_KR');
    return '${formatter.format(amount)} 원';
  }

  @override
  void initState() {
    super.initState();
    // 현재 날짜 초기화
    now = DateTime.now();
    formattedDate = '${now.month}월 ${now.day}일 매장';

    // 데이터 로드
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 테스트용 목업 데이터 로드 함수
  Future<void> _loadMockData() async {
    await Future.delayed(const Duration(seconds: 2)); // 로딩 시간 시뮬레이션

    setState(() {
      // 기본 통계 데이터
      customerCount = 123;
      suspiciousCount = 5;
      dailySales = 1500000;

      // 인기 상품 데이터
      periodProducts[1] = [
        ProductSale(name: '커피', quantity: 52),
        ProductSale(name: '라떼', quantity: 37),
      ];

      periodProducts[2] = [
        ProductSale(name: '텀블러', quantity: 120),
        ProductSale(name: '머그컵', quantity: 85),
        ProductSale(name: '커피빈', quantity: 85),
      ];

      periodProducts[3] = [
        ProductSale(name: '원두', quantity: 520),
        ProductSale(name: '홈세트', quantity: 370),
        ProductSale(name: '기프트카드', quantity: 290),
      ];

      isLoading = false;
    });
  }

  // 실제 서버 데이터 로드 함수
  Future<void> _loadServerData() async {
    try {
      // 소켓 연결
      await socketService.initSocket(SocketConfig.socketURL);

      // 데이터 요청 및 응답 대기
      final result = await socketService.getMainPageData();

      // 데이터 처리
      setState(() {
        // 기본 통계 데이터
        customerCount = result['daily_customer_count'] ?? 0;
        suspiciousCount = result['daily_suspect_count'] ?? 0;
        dailySales = (result['daily_sales'] ?? 0).toDouble();

        // 인기 상품 데이터
        if (result.containsKey('popular_products')) {
          final popularProducts = result['popular_products'];

          // 일별 데이터
          if (popularProducts.containsKey('daily')) {
            periodProducts[1] = List<ProductSale>.from(
                (popularProducts['daily'] as List)
                    .map((item) => ProductSale.fromJson(item)));
          }

          // 월별 데이터
          if (popularProducts.containsKey('monthly')) {
            periodProducts[2] = List<ProductSale>.from(
                (popularProducts['monthly'] as List)
                    .map((item) => ProductSale.fromJson(item)));
          }

          // 연별 데이터
          if (popularProducts.containsKey('yearly')) {
            periodProducts[3] = List<ProductSale>.from(
                (popularProducts['yearly'] as List)
                    .map((item) => ProductSale.fromJson(item)));
          }
        }

        isLoading = false;
      });
    } catch (e) {
      print('서버 데이터 로드 오류: $e');
      // 오류 발생 시 목업 데이터로 대체
      _loadMockData();
    }
  }

  // 데이터 로드 함수 (서버 또는 목업)
  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    // 서버 연결이 가능할 경우 서버 데이터 로드, 아니면 목업 데이터 로드
    bool useServerData = true; // 서버 연결 여부를 확인하는 조건

    if (useServerData) {
      await _loadServerData();
    } else {
      await _loadMockData();
    }
  }

  Widget _buildProductBar(ProductSale product, int rank) {
    // 현재 선택된 기간의 최대 수량 찾기
    final maxQuantity = periodProducts[type]!
        .map((p) => p.quantity)
        .reduce((a, b) => a > b ? a : b);

    // 상대적 너비 계산 (최대 0.7)
    final double relativeWidth = (product.quantity / maxQuantity) * 0.7;

    // 랭크에 따른 색상 설정
    Color barColor;
    switch (rank) {
      case 1:
        barColor = const Color.fromARGB(255, 38, 61, 194); // 인디고
        break;
      case 2:
        barColor = const Color.fromARGB(255, 123, 137, 216); // 밝은 인디고
        break;
      case 3:
        barColor = const Color.fromARGB(255, 189, 197, 240); // 더 밝은 인디고
        break;
      default:
        barColor = const Color(0xFF9FA8DA); // 가장 밝은 인디고
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제품 이름과 수량
          Row(
            children: [
              SizedBox(
                width: 80,
                child: StoreText(
                  "$rank 등",
                  fontSize: 14,
                  color: const Color(0xFF303F9F),
                ),
              ),
              Expanded(
                child: StoreText(
                  product.name,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              StoreText(
                product.quantity.toString(),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 바 차트
          Stack(
            children: [
              // 배경 바
              Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // 실제 데이터 바
              FractionallySizedBox(
                widthFactor: relativeWidth,
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: StoreText(
                "스토어 쉴드",
                fontSize: 30,
              ),
              centerTitle: true,
              backgroundColor: backgroundColor,
              elevation: 0,
              floating: true,
              pinned: false,
              snap: true,
              scrolledUnderElevation: 0, // 스크롤 시 엘리베이션 효과 제거
              surfaceTintColor: Colors.transparent, // 서피스 틴트 제거 (Material 3 효과)
              toolbarHeight: 65,
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
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //오늘의 매장
                        SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height *
                              0.3, // 화면 높이의 30%

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  child: StoreText(
                                    formattedDate,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 6,
                                child: Container(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFAECDFB),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(
                                                    height: 25,
                                                  ),
                                                  const StoreText("고객 수",
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  StoreText(
                                                      customerCount.toString(),
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ],
                                              ),
                                            )),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Container(
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFAECDFB),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(
                                                    height: 25,
                                                  ),
                                                  const StoreText("도난 의심",
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  StoreText(
                                                      suspiciousCount
                                                          .toString(),
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ],
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Expanded(
                                  flex: 5,
                                  child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFAECDFB),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            15.0, 15, 0, 0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const StoreText("매출액",
                                                fontSize: 15,
                                                fontWeight: FontWeight.normal),
                                            StoreText(
                                                formatCurrency(dailySales),
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500)
                                          ],
                                        ),
                                      )))
                            ],
                          ),
                        ),
                        ////바로 가기
                        SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height *
                              0.16, // 화면 높이의 20%

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 15, 0, 3),
                                child: Container(
                                  child: const StoreText(
                                    "바로가기",
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF8E78F6),
                                              Color.fromARGB(255, 74, 65, 238)
                                            ],
                                            begin:
                                                Alignment.topCenter, // 위에서 시작
                                            end: Alignment.bottomCenter,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  pageBuilder: (context,
                                                          animation,
                                                          secondaryAnimation) =>
                                                      const CctvPage(),
                                                  transitionsBuilder: (context,
                                                      animation,
                                                      secondaryAnimation,
                                                      child) {
                                                    return FadeTransition(
                                                      opacity: animation,
                                                      child: child,
                                                    );
                                                  },
                                                  transitionDuration:
                                                      const Duration(
                                                          milliseconds: 300),
                                                ),
                                              );
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 15.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.videocam,
                                                      color: Colors.white,
                                                      size: 20),
                                                  SizedBox(width: 3),
                                                  StoreText(
                                                    '실시간 CCTV',
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF8E78F6),
                                              Color.fromARGB(255, 74, 65, 238)
                                            ],
                                            begin:
                                                Alignment.topCenter, // 위에서 시작
                                            end: Alignment.bottomCenter,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  pageBuilder: (context,
                                                          animation,
                                                          secondaryAnimation) =>
                                                      const ManagementPage(),
                                                  transitionsBuilder: (context,
                                                      animation,
                                                      secondaryAnimation,
                                                      child) {
                                                    return FadeTransition(
                                                      opacity: animation,
                                                      child: child,
                                                    );
                                                  },
                                                  transitionDuration:
                                                      const Duration(
                                                          milliseconds: 300),
                                                ),
                                              );
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 15.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.qr_code,
                                                      color: Colors.white,
                                                      size: 20),
                                                  SizedBox(width: 3),
                                                  StoreText(
                                                    '재고관리',
                                                    fontSize: 13,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF8E78F6),
                                              Color.fromARGB(255, 74, 65, 238)
                                            ],
                                            begin:
                                                Alignment.topCenter, // 위에서 시작
                                            end: Alignment.bottomCenter,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  pageBuilder: (context,
                                                          animation,
                                                          secondaryAnimation) =>
                                                      const SaleshistoryPage(),
                                                  transitionsBuilder: (context,
                                                      animation,
                                                      secondaryAnimation,
                                                      child) {
                                                    return FadeTransition(
                                                      opacity: animation,
                                                      child: child,
                                                    );
                                                  },
                                                  transitionDuration:
                                                      const Duration(
                                                          milliseconds: 300),
                                                ),
                                              );
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 15.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .account_balance_wallet,
                                                      color: Colors.white,
                                                      size: 20),
                                                  SizedBox(width: 3),
                                                  StoreText(
                                                    '매출내역',
                                                    fontSize: 13,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        //인기상품
                        SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height *
                              0.5, // 화면 높이의 30%

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  child: const StoreText(
                                    "인기상품",
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 9,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5),
                                          child: Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      type = 1;
                                                    });
                                                  },
                                                  child: Container(
                                                    child: Column(
                                                      children: [
                                                        StoreText(
                                                          "일",
                                                          fontSize: 19,
                                                          fontWeight: type == 1
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal,
                                                          color: type == 1
                                                              ? const Color(
                                                                  0xFF7568E4)
                                                              : Colors.black,
                                                        ),
                                                        Visibility(
                                                          visible: type == 1,
                                                          child: Container(
                                                            width: 20,
                                                            height: 2,
                                                            color: const Color(
                                                                0xFF7568E4),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      type = 2;
                                                    });
                                                  },
                                                  child: Container(
                                                    child: Column(
                                                      children: [
                                                        StoreText(
                                                          "월",
                                                          fontSize: 19,
                                                          fontWeight: type == 2
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal,
                                                          color: type == 2
                                                              ? const Color(
                                                                  0xFF7568E4)
                                                              : Colors.black,
                                                        ),
                                                        Visibility(
                                                          visible: type == 2,
                                                          child: Container(
                                                            width: 20,
                                                            height: 2,
                                                            color: const Color(
                                                                0xFF7568E4),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      type = 3;
                                                    });
                                                  },
                                                  child: Container(
                                                    child: Column(
                                                      children: [
                                                        StoreText(
                                                          "년",
                                                          fontSize: 19,
                                                          fontWeight: type == 3
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal,
                                                          color: type == 3
                                                              ? const Color(
                                                                  0xFF7568E4)
                                                              : Colors.black,
                                                        ),
                                                        Visibility(
                                                          visible: type == 3,
                                                          child: Container(
                                                            width: 20,
                                                            height: 2,
                                                            color: const Color(
                                                                0xFF7568E4),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      Container(
                                          height: 2,
                                          width: double.infinity,
                                          color: const Color(0xFF757575)),
                                      Expanded(
                                        flex: 9,
                                        child: Container(
                                          width: double.infinity,
                                          color: Colors.white,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 15.0,
                                                horizontal: 10.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // 데이터가 없는 경우 표시할 위젯
                                                if (periodProducts[type]
                                                        ?.isEmpty ??
                                                    true)
                                                  const Center(
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 50.0),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .info_outline,
                                                              size: 40,
                                                              color:
                                                                  Colors.grey),
                                                          SizedBox(height: 10),
                                                          StoreText(
                                                            '판매된 상품이 없습니다.',
                                                            fontSize: 16,
                                                            color: Colors.grey,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                else
                                                  // 데이터가 있는 경우 표시할 위젯
                                                  Expanded(
                                                    child: ListView.separated(
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemCount:
                                                          periodProducts[type]!
                                                              .length,
                                                      separatorBuilder:
                                                          (context, index) =>
                                                              const SizedBox(
                                                                  height: 15),
                                                      itemBuilder:
                                                          (context, index) {
                                                        final product =
                                                            periodProducts[
                                                                type]![index];
                                                        return _buildProductBar(
                                                            product, index + 1);
                                                      },
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
      bottomNavigationBar: const StoreShieldNaviBar(currentIndex: 0)
    );
  }
}

class ProductSale {
  final String name; // 제품 이름
  final int quantity; // 판매 수량

  ProductSale({required this.name, required this.quantity});

  // JSON에서 ProductSale 객체 생성
  factory ProductSale.fromJson(Map<String, dynamic> json) {
    return ProductSale(
      name: json['product_name'] ?? '',
      quantity: json['count'] ?? 0,
    );
  }
}
