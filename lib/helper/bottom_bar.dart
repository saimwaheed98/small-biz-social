import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/providers/bottom_bar_provider.dart';
import 'package:smallbiz/screens/chat_room/ui/chat_room_screen.dart';
import 'package:smallbiz/screens/home/ui/home_screen.dart';
import 'package:smallbiz/screens/notification/notification_screen.dart';
import 'package:smallbiz/screens/subscription_setup/ui/subscription_setup_screen.dart';
import 'package:smallbiz/screens/user_profile/ui/user_profile_screen.dart';
import 'package:smallbiz/screens/users_chat/ui/user_chat_screen.dart';
import 'package:smallbiz/utils/colors.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    Key? key,
  }) : super(key: key);

  static const routename = '/bottom-bar';

  List<Widget> _buildScreens() => [
        HomeScreen(),
        const ChatRoomScreen(),
        SubscriptionSetup(isNewUser: false),
        const NotificationScreen(),
        UserChat(),
        UserProfile(
          isUser: true,
          isNeedBackButton: false,
        )
      ];

  List<PersistentBottomNavBarItem> _navBarsItems(BuildContext context) {
    return [
      PersistentBottomNavBarItem(
          icon: SvgPicture.asset(
            'assets/icons/active_home.svg',
            height: 22,
            width: 22,
          ),
          title: "Home",
          textStyle: GoogleFonts.dmSans(color: buttonColor),
          inactiveColorSecondary: Colors.black,
          inactiveIcon: SvgPicture.asset(
            'assets/icons/home1.svg',
            height: 18,
            width: 18,
          ),
          activeColorPrimary: Colors.transparent,
          activeColorSecondary: buttonColor),
      PersistentBottomNavBarItem(
          icon: SvgPicture.asset(
            'assets/icons/active_cummunity.svg',
            height: 21,
            width: 21,
          ),
          inactiveIcon: SvgPicture.asset(
            'assets/icons/community_icon.svg',
            height: 21,
            width: 21,
          ),
          title: "Chat Room",
          textStyle: GoogleFonts.dmSans(color: buttonColor),
          activeColorPrimary: Colors.transparent,
          inactiveColorPrimary: Colors.black,
          activeColorSecondary: buttonColor),
      PersistentBottomNavBarItem(
          icon: SvgPicture.asset(
            'assets/icons/active_subscription.svg',
            height: 20,
            width: 20,
          ),
          inactiveIcon: SvgPicture.asset(
            'assets/icons/diamond_icon.svg',
            height: 17,
            width: 17,
          ),
          title: "Subscription",
          textStyle: GoogleFonts.dmSans(color: buttonColor),
          activeColorPrimary: Colors.transparent,
          inactiveColorPrimary: Colors.black,
          activeColorSecondary: buttonColor),
      PersistentBottomNavBarItem(
          icon: SvgPicture.asset(
            'assets/icons/noti_icon.svg',
            height: 24,
            width: 24,
          ),
          inactiveIcon: SvgPicture.asset(
            'assets/icons/noti_icon.svg',
            height: 20,
            width: 20,
          ),
          title: "Notification",
          textStyle: GoogleFonts.dmSans(color: buttonColor),
          activeColorPrimary: Colors.transparent,
          inactiveColorPrimary: Colors.black,
          activeColorSecondary: buttonColor),
      PersistentBottomNavBarItem(
          icon: SvgPicture.asset(
            'assets/icons/active_chat.svg',
            height: 22,
            width: 22,
          ),
          inactiveIcon: SvgPicture.asset(
            'assets/icons/chat_icon.svg',
            height: 20,
            width: 20,
          ),
          title: "Chat",
          textStyle: GoogleFonts.dmSans(color: buttonColor),
          activeColorPrimary: Colors.transparent,
          inactiveColorPrimary: Colors.black,
          activeColorSecondary: buttonColor),
      PersistentBottomNavBarItem(
          icon: const Icon(Icons.person_rounded),
          inactiveIcon: const Icon(
            Icons.person_outlined,
            size: 26,
            color: black,
          ),
          title: "Profile",
          textStyle: GoogleFonts.dmSans(color: buttonColor),
          activeColorPrimary: Colors.transparent,
          inactiveColorPrimary: Colors.black,
          activeColorSecondary: buttonColor),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<BottomBarProvider>(context, listen: false);
    debugPrint('building');
    return Scaffold(
      body: PersistentTabView(
        context,
        controller: provider.persistentTabController,
        screens: _buildScreens(),
        items: _navBarsItems(context),
        resizeToAvoidBottomInset: true,
        onItemSelected: (value) => provider.changeIndex(value),
        navBarHeight: MediaQuery.of(context).viewInsets.bottom > 0
            ? 0.0
            : kBottomNavigationBarHeight,
        selectedTabScreenContext: (context) {
          // You can use this to get the context of the selected tab
        },
        backgroundColor: Colors.white,
        hideNavigationBar: false,
        decoration: const NavBarDecoration(
          colorBehindNavBar: Colors.indigo,
        ),
        itemAnimationProperties: const ItemAnimationProperties(
          duration: Duration(milliseconds: 400),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: const ScreenTransitionAnimation(
          animateTabTransition: true,
        ),
        navBarStyle: NavBarStyle.style10,
      ),
    );
  }
}
