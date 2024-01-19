import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smallbiz/utils/colors.dart';

class FieldText extends StatefulWidget {
  const FieldText({
    Key? key,
    this.obscureText = false,
    required this.labelText,
    this.errorText = '',
    required this.controller,
    this.keyBoardType = TextInputType.name,
    this.validater,
  }) : super(key: key);

  final String labelText;
  final String errorText;
  final bool obscureText;
  final TextInputType keyBoardType;
  final TextEditingController controller;
  final String? Function(String?)? validater;

  @override
  // ignore: library_private_types_in_public_api
  _FieldTextState createState() => _FieldTextState();
}

class _FieldTextState extends State<FieldText> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      // Rebuild the widget when focus changes
    });
  }

  @override
  Widget build(BuildContext context) {
    final labelColor = _focusNode.hasFocus ? primaryPinkColor : Colors.grey;

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: SizedBox(
        height: 46,
        child: TextFormField(
          keyboardType: widget.keyBoardType,
          style: GoogleFonts.dmSans(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          obscureText: widget.obscureText,
          controller: widget.controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            fillColor: const Color(0xffE7E7E7),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(
                color: primaryPinkColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(
                color: primaryPinkColor,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: BorderSide.none,
            ),
            labelText: widget.labelText,
            labelStyle: GoogleFonts.dmSans(
              color: labelColor,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            counterText: '',
          ),
          validator: widget.validater,
        ),
      ),
    );
  }
}
