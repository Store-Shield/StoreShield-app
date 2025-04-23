import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StoreText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;

  const StoreText(
    this.text, {
    this.fontSize = 22,
    this.color = Colors.black,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.jua(
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
        color: color,
      ),
    );
  }
}
