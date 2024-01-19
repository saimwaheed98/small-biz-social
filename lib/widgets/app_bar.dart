import 'package:flutter/material.dart';
import 'package:smallbiz/helper/text_style.dart';
import 'package:smallbiz/widgets/profile_avatar.dart';

class ScaffoldAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Function()? onPressed;
  const ScaffoldAppBar({super.key, required this.title, this.onPressed});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: AppTextStyle(
            textName: title,
            textColor: Colors.black,
            textSize: 16,
            textWeight: FontWeight.w600),
        centerTitle: true,
        // leading: IconButton(
        //     onPressed: onPressed,
        //     icon: const Icon(
        //       Icons.arrow_back_outlined,
        //       color: Color(0xff610030),
        //     )),
        actions: const [
          ProfileAvatar(),
        ],
      ),
    );
  }
}
