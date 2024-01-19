import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smallbiz/utils/colors.dart';

class GestureContainer extends StatelessWidget {
  const GestureContainer(
      {super.key,
      required this.containerName,
      required this.onTap,
      this.containerColor = buttonColor,
      this.isLoading = false});
  final String containerName;
  final VoidCallback onTap;
  final bool isLoading;
  final Color containerColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 22),
      width: double.infinity,
      height: 46,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), color: containerColor),
      child: TextButton(
          onPressed: () {
            onTap();
          },
          child: isLoading
              ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                    color: Colors.white,
                    backgroundColor: Colors.grey,
                    strokeCap: StrokeCap.round,
                    strokeWidth: 2,
                  ),
              )
              : Text(
                  containerName,
                  style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                )),
    );
  }
}
