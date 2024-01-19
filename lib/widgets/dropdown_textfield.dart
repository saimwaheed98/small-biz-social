import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smallbiz/helper/text_style.dart';
import 'package:smallbiz/utils/colors.dart';

class DropDownFieldText extends StatefulWidget {
  const DropDownFieldText({
    super.key,
    required this.onTap,
    required this.hintText,
    required this.keyboardType,
    required this.cnt,
    required this.inputName,
    this.obscureText = false,
    this.inputLenth = 30,
    required this.isRequired,
    this.textSize = 12,
  });
  final String hintText;
  final TextInputType keyboardType;
  final VoidCallback onTap;
  final TextEditingController cnt;
  final bool obscureText;
  final int inputLenth;
  final String inputName;
  final bool isRequired;
  final double textSize;

  @override
  State<DropDownFieldText> createState() => _DropDownFieldTextState();
}

class _DropDownFieldTextState extends State<DropDownFieldText> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 7, bottom: 10),
          child: AppTextStyle(
              textName: widget.inputName,
              textColor: primaryPinkColor,
              textSize: 12,
              textWeight: FontWeight.w500),
        ),
        TextFormField(
          maxLength: widget.inputLenth,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          style: GoogleFonts.dmSans(
            color: Colors.black,
            fontSize: widget.textSize,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            suffixIcon: widget.isRequired == false
                ? null
                : IconButton(
                    onPressed: () => widget.onTap(),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.black,
                    )),
            contentPadding: const EdgeInsets.all(5),
            hintText: widget.hintText,
            hintStyle: GoogleFonts.inter(
              color: const Color(0xff204A69),
              fontSize: widget.textSize,
              fontWeight: FontWeight.w400,
            ),
            fillColor: const Color(0xffE7E7E7),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            counterText: '',
          ),
          controller: widget.cnt,
          validator: (value) {
            if (value == null) {
              return "Required field";
            } else {
              return null;
            }
          },
        ),
      ],
    );
  }
}
