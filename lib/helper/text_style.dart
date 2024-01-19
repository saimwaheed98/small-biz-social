import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyle extends StatelessWidget {
  const AppTextStyle(
      {super.key,
      required this.textName,
      required this.textColor,
      required this.textSize,
      this.maxLines,
      required this.textWeight});
  final String textName;
  final Color textColor;
  final double textSize;
  final FontWeight textWeight;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Text(
      textName,
      maxLines: maxLines,
      style: GoogleFonts.dmSans(
          fontSize: textSize, fontWeight: textWeight, color: textColor),
    );
  }
}
