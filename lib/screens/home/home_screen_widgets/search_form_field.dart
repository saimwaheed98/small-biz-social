import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/screens/home/provider/home_screen_provider.dart';
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
    var provider = Provider.of<HomeScreenProvider>(context, listen: false);
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
                borderSide:
                    const BorderSide(color: Color(0xffFFCBE5), width: 1)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide:
                    const BorderSide(color: Color(0xffFFCBE5), width: 1)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none),
            suffixIcon: IconButton(
              onPressed: () {
                provider.searching(false);
                searchController.clear();
                onChanged('');
              },
              icon: const Icon(
                Icons.cancel,
                color: primaryTextColor,
                size: 20,
              ),
            )),
        autofocus: true,
        onChanged: onChanged,
      ),
    );
  }
}
