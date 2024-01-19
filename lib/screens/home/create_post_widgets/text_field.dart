import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smallbiz/utils/colors.dart';

class CreatePostTextField extends StatelessWidget {
  final TextEditingController controller;
  final int? maxLength;
  final int? maxLines;
  final String hintText;
  const CreatePostTextField(
      {super.key,
      required this.controller,
      required this.maxLength,
      required this.maxLines,
      required this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      style: GoogleFonts.dmSans(
          fontSize: 16, color: Colors.black, fontWeight: FontWeight.w400),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.dmSans(
          fontSize: 20,
          color: primaryTextColor,
          fontWeight: FontWeight.w400,
        ),
        border: InputBorder.none,
      ),
    );
  }
}
