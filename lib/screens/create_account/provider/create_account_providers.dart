import 'package:flutter/material.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/helper/warning_helper.dart';
import 'package:smallbiz/screens/create_account/ui/profile_picture_screen.dart';

class CreateAccountProviders extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  bool areAllFieldsValid() {
    return email.text.isNotEmpty &&
        firstName.text.isNotEmpty &&
        lastName.text.isNotEmpty &&
        password.text.isNotEmpty &&
        password.text == reEnterPassword.text;
    // You can add more complex validation logic as needed
  }

  final email = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final password = TextEditingController();
  final reEnterPassword = TextEditingController();

  clearControllers() {
    email.text = '';
    firstName.text = '';
    lastName.text = '';
    password.text = '';
    reEnterPassword.text = '';
  }

  bool isPasswordValid() {
    final String pass = password.text;
    const String pattern = r'^(?=.*[!@#$%^&*()_+\-=\[\]{};:\|<>./?]).{8,}$';
    final RegExp regex = RegExp(pattern);
    return pass.isNotEmpty && regex.hasMatch(pass);
  }

  Future<void> createAccount(context) async {
    try {
      // for creating a new user with email and password
      Apis.auth
          .createUserWithEmailAndPassword(
              email: email.text.toString().trim(),
              password: password.text.toString().trim())
          .then((value) {
        setLoading(true);
        // for creating a new user in firestore
        Apis.createUser(
                firstname: firstName.text.toString(),
                lastname: lastName.text.toString())
            .then((value) {
          WarningHelper.showWarningDialog(context, 'Account Created',
              'Your Account has created Successfully');
          Navigator.pushReplacementNamed(
            context,
            ProfilePicture.routeName,
          );
          clearControllers();
        });
      }).onError((error, stackTrace) {
        debugPrint('error while creating account $error');
        setLoading(false);
        WarningHelper.showWarningDialog(context, 'Error', '$error');
      });
    } catch (e) {
      setLoading(false);
      debugPrint('error while creating account $e');
      WarningHelper.showWarningDialog(
          context, 'Error', 'error while creating account');
    }
  }

  bool _isObscure = false;
  bool get isObscure => _isObscure;

  void toggleObscure() {
    _isObscure = !_isObscure;
    notifyListeners();
  }

  bool _isObscure2 = false;
  bool get isObscure2 => _isObscure2;

  void toggleObscure2() {
    _isObscure2 = !_isObscure2;
    notifyListeners();
  }
}
