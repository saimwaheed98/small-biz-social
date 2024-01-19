import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/helper/text_style.dart';
import 'package:smallbiz/screens/create_account/ui/create_account_screen.dart';
import 'package:smallbiz/screens/sign_in/provider/sign_in_screen_provider.dart';
import 'package:smallbiz/utils/colors.dart';
import 'package:smallbiz/widgets/gesture_container.dart';
import 'package:smallbiz/widgets/text_field.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  static const routeName = '/create-account-screen';

  @override
  Widget build(BuildContext context) {
    var signinProvider = Provider.of<SigninProvider>(context);
    return WillPopScope(
      onWillPop: () {
        if (signinProvider.emailController.text.isNotEmpty &&
            signinProvider.passwordController.text.isNotEmpty) {
          signinProvider.clearControllers();
        } else {
          return Future.value(false);
        }
        return Future.value(false);
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: scaffoldColor,
            body: Padding(
              padding: const EdgeInsets.only(
                  top: 56, left: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppTextStyle(
                      textName: 'Welcome Again',
                      textColor: Colors.black,
                      textSize: 24,
                      textWeight: FontWeight.w900),
                  const SizedBox(
                    height: 5,
                  ),
                  const AppTextStyle(
                      textName: 'Sign in to your account to acces the \ndata',
                      textColor: primaryTextColor,
                      textSize: 12,
                      textWeight: FontWeight.w400),
                  const Spacer(),
                  // text Form Fields
                  Padding(
                      padding: const EdgeInsets.only(top: 67, right: 48),
                      child: Consumer<SigninProvider>(
                        builder: (context, provider, child) {
                          return Form(
                            key: provider.formKey,
                            child: Column(
                              children: [
                                FieldText(
                                  controller: signinProvider.emailController,
                                  labelText: 'Entre your email',
                                  errorText: 'Please Enter your email',
                                  keyBoardType: TextInputType.emailAddress,
                                  validater: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    return null;
                                  },
                                ),
                                FieldText(
                                    controller:
                                        signinProvider.passwordController,
                                    obscureText: true,
                                    labelText: 'Create new password',
                                    errorText: 'Please enter a password',
                                    keyBoardType: TextInputType.visiblePassword,
                                    validater: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      return null;
                                    }),
                              ],
                            ),
                          );
                        },
                      )),
                  Consumer<SigninProvider>(
                    builder: (context, provider, child) {
                      var gestureContainer = GestureContainer(
                          containerColor: provider.areAllFieldsValid()
                              ? buttonColor
                              : Colors.grey,
                          isLoading: provider.isLoading,
                          containerName: 'Sign in',
                          onTap: () {
                            if (provider.formKey.currentState!.validate()) {
                              provider.emailLogin(context);
                            }
                          });
                      return gestureContainer;
                    },
                  ),

                  const Spacer(flex: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppTextStyle(
                          textName: 'Dont Have An Account?',
                          textColor: primaryTextColor,
                          textSize: 14,
                          textWeight: FontWeight.w700),
                      TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateAccount(),
                                ));
                          },
                          child: const AppTextStyle(
                              textName: 'Sign up',
                              textColor: Colors.blue,
                              textSize: 14,
                              textWeight: FontWeight.w700)),
                    ],
                  )
                ],
              ),
            )),
      ),
    );
  }
}
