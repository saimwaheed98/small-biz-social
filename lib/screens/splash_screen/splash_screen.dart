import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/helper/images_strings.dart';
import 'package:smallbiz/screens/splash_screen/providers/splash_screen_provider.dart';
import 'package:smallbiz/utils/colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  static const routeName = '/splash-screen';

  @override
  Widget build(BuildContext context) {
    Provider.of<InternetConnectionProvider>(context, listen: false)
        .initiallize(context);
    Provider.of<InternetConnectionProvider>(context, listen: false).getInfo();
    return Scaffold(
      backgroundColor: scaffoldColor,
      body: Center(
        child: SizedBox(
            width: 241,
            height: 241,
            child: Image.asset(
              Images.splashImage,
              fit: BoxFit.cover,
            )),
      ),
    );
  }
}
