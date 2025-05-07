import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/suspectorData.dart';
import '../suspect_detail_page.dart';
import '../../fontstyle.dart';

class SuspectItem extends StatelessWidget {
  final SuspectData suspect;
  final VoidCallback? onTap;

  const SuspectItem({
    super.key,
    required this.suspect,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: InkWell(
        onTap: onTap ??
            () {
              // 상세 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SuspectDetailPage(suspect: suspect),
                ),
              );
            },
        child: Row(
          children: [
            // 용의자 이미지
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(8),
              ),
              child: SizedBox(
                width: 100,
                height: 80,
                child: suspect.getImage(
                  width: 100,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // 용의자 정보
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StoreText(
                          'ID ${suspect.id}',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: StoreText(
                            suspect.calState,
                            fontSize: 12,
                            color: Colors.red.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    StoreText(
                      '${DateFormat('HH:mm').format(suspect.comeIn)} - ${DateFormat('HH:mm').format(suspect.comeOut)}',
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
