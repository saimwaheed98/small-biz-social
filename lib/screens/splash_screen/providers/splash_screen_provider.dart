import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smallbiz/helper/bottom_bar.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/helper/text_style.dart';
import 'package:smallbiz/helper/warning_helper.dart';
import 'package:smallbiz/screens/create_account/ui/create_account_screen.dart';
import 'package:smallbiz/utils/colors.dart';
import 'package:smallbiz/widgets/gesture_container.dart';

class InternetConnectionProvider extends ChangeNotifier {
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  setConnected(bool value) {
    _isConnected = value;
    notifyListeners();
  }

  initiallize(context) async {
    if (Apis.auth.currentUser != null) {
      SystemChannels.lifecycle.setMessageHandler((message) {
        if (Apis.auth.currentUser != null) {
          debugPrint('SystemChannels> $message');
          if (message.toString().contains('resume')) {
            Apis.updateActiveStatus(true);
          } else if (message.toString().contains('pause')) {
            Apis.updateActiveStatus(false);
          } else if (message.toString().contains('inactive')) {
            // Handle inactive state (if needed)
            Apis.updateActiveStatus(false);
          } else if (message.toString().contains('detached')) {
            // Handle detached state (if needed)
            Apis.updateActiveStatus(false);
          }
        }
        return Future.value(message);
      });
    }
    await checkInternetConnection();
    if (isConnected) {
      _navigateToNextScreen(context);
    } else {
      internetDialouge(context, false);
    }
  }

  Future<bool> checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      setConnected(true);
      return true;
    } else {
      setConnected(false);
      return false;
    }
  }

  getInfo() {
    if (Apis.auth.currentUser != null) {
      Apis.getSelfInfo();
      Apis.userDetail;
      Apis.getLoginInfo(Apis.auth.currentUser!.uid);
    } else {
      return;
    }
  }

  Future<void> _navigateToNextScreen(BuildContext context) async {
    Future.delayed(const Duration(seconds: 3), () {
      if (Apis.auth.currentUser != null) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const BottomBar()));
      } else {
        Navigator.pushReplacementNamed(context, CreateAccount.routeName);
      }
    });
  }

  internetDialouge(context, bool isDismiss) {
    return showDialog(
        barrierDismissible: isDismiss,
        context: context,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppTextStyle(
                      textName: 'No Internet',
                      textColor: Colors.black,
                      textSize: 24,
                      textWeight: FontWeight.bold),
                  const AppTextStyle(
                      textName:
                          'Please check your internet connection and try again.',
                      textColor: primaryTextColor,
                      textSize: 16,
                      textWeight: FontWeight.normal),
                  GestureContainer(
                      containerName: 'Try Again',
                      onTap: () async {
                        bool isConnected = await checkInternetConnection();
                        if (isConnected) {
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        } else {
                          WarningHelper.toastMessage(
                              'Please check your internet connection and try again.');
                        }
                      }),
                  GestureContainer(
                      containerName: 'Cancel',
                      onTap: () {
                        SystemChannels.platform
                            .invokeMethod('SystemNavigator.pop');
                      })
                ],
              ),
            ),
          );
        });
  }
}
