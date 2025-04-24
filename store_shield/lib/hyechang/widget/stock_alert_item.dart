import 'package:flutter/material.dart';
import 'package:store_shield/hyechang/fontstyle.dart';
import '../model/stock_alert_data.dart';

class StockAlertItem extends StatelessWidget {
  final StockAlertData stockAlert;

  const StockAlertItem({
    super.key,
    required this.stockAlert,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 10, 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 10, 0, 12),
        child: Row(
          children: [
            // 제품 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 60,
                height: 60,
                child: stockAlert.getImage(width: 60, height: 60),
              ),
            ),
            const SizedBox(width: 16),
            // 제품 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StoreText(
                    stockAlert.productName,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Row(
                            children: [
                              StoreText(
                                '현재 재고: ',
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                              StoreText(
                                '${stockAlert.currentStock}개',
                                fontSize: 14,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 100,
                      ),
                      const Expanded(
                        flex: 1,
                        child: StoreText(
                          "재고 부족",
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
