import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smallbiz/utils/colors.dart';

class LikeCounterContainer extends StatelessWidget {
  final String containerImage;
  final String containerText;
  const LikeCounterContainer(
      {super.key, required this.containerImage, required this.containerText});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 25,
      width: 56,
      decoration: BoxDecoration(
          color: scaffoldColor, borderRadius: BorderRadius.circular(28)),
      child: Row(children: [
        const SizedBox(
          width: 5,
        ),
        SizedBox(
          height: 25,
          width: 25,
          child: Image.asset(
            containerImage,
            fit: BoxFit.fitHeight,
          ),
        ),
        Text(
          containerText,
          style: GoogleFonts.dmSans(
              color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
        )
      ]),
    );
  }
}
