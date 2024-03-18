import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/helper/images_strings.dart';
import 'package:smallbiz/screens/splash_screen/providers/splash_screen_provider.dart';
import 'package:smallbiz/utils/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const routeName = '/splash-screen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkForUpdate();
  }

  Future<void> checkForUpdate() async {
    debugPrint('checking for Update');
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
          debugPrint('update available');
          update();
        }
      });
    }).catchError((e) {
      debugPrint(e.toString());
    });
  }

  void update() async {
    debugPrint('Updating');
    await InAppUpdate.startFlexibleUpdate();
    InAppUpdate.completeFlexibleUpdate().then((_) {}).catchError((e) {
      debugPrint(e.toString());
    });
  }

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
