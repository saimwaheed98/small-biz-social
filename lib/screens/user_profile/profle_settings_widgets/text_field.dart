import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smallbiz/utils/colors.dart';

class ProfileSettingTextField extends StatelessWidget {
  final String lableText;
  final TextEditingController? controller;
  final TextInputType? textInputType;
  final bool? canEdit;
  final Function(String)? onSubmitted;
  final int? maxLength;
  final String? counterText;

  const ProfileSettingTextField(
      {super.key,
      required this.lableText,
      this.controller,
      this.textInputType,
      this.onSubmitted,
      this.maxLength,
      this.counterText,
      this.canEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 16),
      child: SizedBox(
        height: 43,
        child: TextFormField(
          maxLength: maxLength ?? 50,
          canRequestFocus: canEdit ?? true,
          decoration: InputDecoration(
            fillColor: white,
            filled: true,
            labelText: lableText,
            labelStyle: GoogleFonts.dmSans(
              color: primaryTextColor,
              fontSize: 15,
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none),
            counterText: counterText?.isEmpty ?? true ? '' : counterText,
          ),
          controller: controller,
          keyboardType: textInputType ?? TextInputType.name,
          onFieldSubmitted: onSubmitted,
        ),
      ),
    );
  }
}
