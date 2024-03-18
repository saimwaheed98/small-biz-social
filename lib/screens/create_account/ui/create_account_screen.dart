import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/helper/text_style.dart';
import 'package:smallbiz/screens/create_account/provider/create_account_providers.dart';
import 'package:smallbiz/screens/sign_in/ui/sign_in_screen.dart';
import 'package:smallbiz/utils/colors.dart';
import 'package:smallbiz/widgets/gesture_container.dart';
import 'package:smallbiz/widgets/text_field.dart';

class CreateAccount extends StatelessWidget {
  CreateAccount({super.key});

  static const routeName = '/create-account-screen';
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    // provider for this screen
    final provider =
        Provider.of<CreateAccountProviders>(context, listen: false);
    // form Key validation

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: scaffoldColor,
        body: Padding(
          padding:
              const EdgeInsets.only(top: 56, left: 16, right: 16, bottom: 16),
          child: Column(
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: CustomScrollView(slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppTextStyle(
                            textName: 'Create An Account',
                            textColor: Colors.black,
                            textSize: 24,
                            textWeight: FontWeight.w900),
                        const SizedBox(
                          height: 5,
                        ),
                        const AppTextStyle(
                            textName:
                                'To become a member please enter the following details.',
                            textColor: primaryTextColor,
                            textSize: 12,
                            textWeight: FontWeight.w400),
                        // text Form Fields
                        Padding(
                            padding: const EdgeInsets.only(top: 67, right: 48),
                            child: Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  FieldText(
                                    controller: provider.firstName,
                                    labelText: 'First Name',
                                    errorText: 'Please Enter your first name',
                                    validater: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please Enter your first name';
                                      }
                                      return null;
                                    },
                                  ),
                                  FieldText(
                                    controller: provider.lastName,
                                    labelText: 'Last Name',
                                    errorText: 'Please Enter your last name',
                                    validater: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please Enter your last name';
                                      }
                                      return null;
                                    },
                                  ),
                                  FieldText(
                                    controller: provider.email,
                                    labelText: 'Email',
                                    errorText: 'Please Enter your email',
                                    keyBoardType: TextInputType.emailAddress,
                                    validater: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter an email';
                                      } else if (!value.contains('@')) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  Consumer<CreateAccountProviders>(
                                      builder: (context, provider, child) {
                                    return FieldText(
                                      controller: provider.password,
                                      obscureText: provider.isObscure,
                                      labelText: 'Create New Password',
                                      errorText: 'Please enter a password',
                                      keyBoardType:
                                          TextInputType.visiblePassword,
                                      validater: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter a password';
                                        } else if (value.length < 8) {
                                          return 'Password must be at least 8 characters long';
                                        } else if (!value.contains(RegExp(
                                            r'[!@#$%^&*(),.?":{}|<>]'))) {
                                          return 'Password must contain a special character';
                                        }
                                        return null;
                                      },
                                      suffixIxon: IconButton(
                                          onPressed: () {
                                            provider.toggleObscure();
                                          },
                                          icon: Icon(
                                            provider.isObscure
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: buttonColor,
                                            size: 15,
                                          )),
                                    );
                                  }),
                                  Consumer<CreateAccountProviders>(
                                      builder: (context, provider, child) {
                                    return FieldText(
                                      controller: provider.reEnterPassword,
                                      obscureText: provider.isObscure2,
                                      labelText: 'Re-enter password',
                                      errorText: 'Please Re-enter a password',
                                      keyBoardType:
                                          TextInputType.visiblePassword,
                                      validater: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please Re-enter a password';
                                        } else if (value !=
                                            provider.password.text) {
                                          return 'Passwords do not match';
                                        }
                                        return null;
                                      },
                                      suffixIxon: IconButton(
                                          onPressed: () {
                                            provider.toggleObscure2();
                                          },
                                          icon: Icon(
                                            provider.isObscure2
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: buttonColor,
                                            size: 15,
                                          )),
                                    );
                                  }),
                                ],
                              ),
                            )),
                        Consumer<CreateAccountProviders>(
                            builder: (context, caProvider, child) {
                          return GestureContainer(
                              containerName: 'Next',
                              isLoading: caProvider.isLoading,
                              containerColor: caProvider.areAllFieldsValid()
                                  ? buttonColor
                                  : Colors.grey,
                              onTap: () {
                                if (formKey.currentState!.validate()) {
                                  if (!caProvider.isPasswordValid()) {
                                    throw 'Password must be at least 8 characters long and contain a special character.';
                                  }
                                  if (caProvider.password.text !=
                                      caProvider.reEnterPassword.text) {
                                    throw 'Passwords do not match.';
                                  }
                                  if (caProvider.isPasswordValid() ||
                                      caProvider.password.text !=
                                          caProvider.reEnterPassword.text) {
                                    caProvider.createAccount(context);
                                  }
                                }
                              });
                        })
                      ],
                    ),
                  ),
                ]),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppTextStyle(
                      textName: 'Already have an account?',
                      textColor: primaryTextColor,
                      textSize: 14,
                      textWeight: FontWeight.w700),
                  TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignInScreen(),
                            ));
                      },
                      child: const AppTextStyle(
                          textName: 'Sign in',
                          textColor: Colors.blue,
                          textSize: 14,
                          textWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: null,
      ),
    );
  }
}
