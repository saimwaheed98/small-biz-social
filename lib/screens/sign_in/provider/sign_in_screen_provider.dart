import 'package:flutter/material.dart';
import 'package:smallbiz/helper/bottom_bar.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/helper/warning_helper.dart';

class SigninProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  // form Key validation
  var _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKey => _formKey;
  setFormKey(GlobalKey<FormState> formKey) {
    _formKey = formKey;
    notifyListeners();
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // dispose the controllers
  void clearControllers() {
    emailController.clear();
    passwordController.clear();
  }

  // check all the fields are filled
  bool areAllFieldsValid() {
    return emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty;
    // You can add more complex validation logic as needed
  }

  Future<void>? emailLogin(context) async {
    try {
      setLoading(true);
      await Apis.auth
          .signInWithEmailAndPassword(
              email: emailController.text.toString(),
              password: passwordController.text.toString())
          .then((value) {
        Apis.getLoginInfo(value.user!.uid);
        Navigator.pushReplacementNamed(context, BottomBar.routename);
        clearControllers();
        debugPrint('Login Successfully');
        WarningHelper.showWarningDialog(context, 'Login', 'Login Successfully');
      });
    } catch (e) {
      setLoading(false);
      debugPrint('Error While Rendering Login');
      WarningHelper.showWarningDialog(
          context, 'Check Connection', 'Please Check Your internet Connection');
    } finally {
      setLoading(false);
    }
  }
}
