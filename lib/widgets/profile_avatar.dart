import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/helper/shimmer_effect.dart';
import 'package:smallbiz/screens/user_profile/ui/user_profile_screen.dart';
import 'package:smallbiz/utils/colors.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const SizedBox(
            height: 50,
            width: 50,
          ),
          InkWell(
            onTap: () {
              PersistentNavBarNavigator.pushNewScreen(context,
                  withNavBar: true, screen:  UserProfile());
            },
            child: CachedNetworkImage(
              imageUrl: Apis.userDetail.profilePicture,
              imageBuilder: (context, imageProvider) => Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  const AvatarLoading(radius: 22),
              errorWidget: (context, url, error) => const Icon(Icons.person),
            ),
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: Container(
                alignment: Alignment.center,
                height: 12,
                width: 12,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.white),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 10,
                  color: buttonColor,
                )),
          )
        ],
      ),
    );
  }
}
