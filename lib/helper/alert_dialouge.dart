import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smallbiz/helper/text_style.dart';
import 'package:smallbiz/utils/colors.dart';

class Dialouge extends StatelessWidget {
  final String image;
  final String message;
  final String details;
  final String buttonText;
  final VoidCallback onPressed;
  const Dialouge(
      {super.key,
      required this.buttonText,
      required this.details,
      required this.image,
      required this.message,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(37.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        height: 460.0,
        width: 320.0,
        padding:
            const EdgeInsets.only(top: 20, bottom: 20, left: 21, right: 21),
        decoration: BoxDecoration(
          color: scaffoldColor,
          borderRadius: BorderRadius.circular(37.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height: 137,
                width: 171,
                child: Image.asset(
                  image,
                )),
            const SizedBox(height: 20),
            Text(
              message,
              style:
                  GoogleFonts.dmSans(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 10, bottom: 10, left: 15, right: 15),
              child: Text(
                details,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: primaryTextColor),
              ),
            ),
            const Spacer(),
            Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18), color: buttonColor),
              child: TextButton(
                  onPressed: () => onPressed(),
                  child: AppTextStyle(
                      textName: buttonText,
                      textColor: Colors.white,
                      textSize: 15,
                      textWeight: FontWeight.w500)),
            )
          ],
        ),
      ),
    );
  }
}
