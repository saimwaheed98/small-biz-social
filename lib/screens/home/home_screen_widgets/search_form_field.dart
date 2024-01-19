import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smallbiz/utils/colors.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.searchController,
    required this.onChanged,
  });
  final TextEditingController searchController;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextFormField(
        controller: searchController,
        style: GoogleFonts.dmSans(
            fontSize: 12, color: Colors.black, fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(10),
          filled: true,
          fillColor: Colors.white,
          hintText: 'Search',
          hintStyle: GoogleFonts.dmSans(
            fontSize: 10,
            color: primaryTextColor,
            fontWeight: FontWeight.w400,
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Color(0xffFFCBE5), width: 1)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Color(0xffFFCBE5), width: 1)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              alignment: Alignment.center,
              height: 26,
              width: 26,
              decoration: const BoxDecoration(
                  color: buttonColor, shape: BoxShape.circle),
              child: SvgPicture.asset(
                'assets/icons/search_icon.svg',
                height: 15,
                width: 15,
                // ignore: deprecated_member_use
                color: Colors.white,
              ),
            ),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
