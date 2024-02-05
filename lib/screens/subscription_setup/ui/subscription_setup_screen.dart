import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/helper/images_strings.dart';
import 'package:smallbiz/helper/text_style.dart';
import 'package:smallbiz/helper/warning_helper.dart';
import 'package:smallbiz/providers/stripe.dart';
import 'package:smallbiz/screens/profile_percent_indicater/profile_percent_indicater.dart';
import 'package:smallbiz/screens/subscription_setup/provider/subscription_setup.dart';
import 'package:smallbiz/utils/colors.dart';
import 'package:smallbiz/widgets/gesture_container.dart';
import 'package:smallbiz/widgets/text_field.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionSetup extends StatelessWidget {
  SubscriptionSetup({super.key, this.isNewUser = true});
  final bool isNewUser;

  static const routename = "/subscription-setup";
  final Uri _termsUrl = Uri.parse(
      'https://firebasestorage.googleapis.com/v0/b/small-biz-social-30ff3.appspot.com/o/Terms.pdf?alt=media&token=c8b6546b-0e43-4792-ae89-722fe41fc8ce');
  final Uri _privacyUrl = Uri.parse(
      'https://firebasestorage.googleapis.com/v0/b/small-biz-social-30ff3.appspot.com/o/Privacy%20Policy.pdf?alt=media&token=d42e769f-3efd-40a9-b435-93974d6bcb29');

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<PaymentController>(context, listen: false);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: scaffoldColor,
          body: Padding(
            padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Apis.userDetail.subscription == false
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // if the new user is creating the account only show the skip text
                                if (isNewUser == true)
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushReplacementNamed(
                                                ProfilePercentage.routeName);
                                      },
                                      child: const AppTextStyle(
                                          textName: 'Skip',
                                          textColor: primaryPinkColor,
                                          textSize: 15,
                                          textWeight: FontWeight.w500),
                                    ),
                                  ),
                                SizedBox(
                                  height: isNewUser == true
                                      ? 10
                                      : MediaQuery.of(context).size.width * 0.2,
                                ),
                                const AppTextStyle(
                                    textName: 'Subscription Sign Up',
                                    textColor: Colors.black,
                                    textSize: 24,
                                    textWeight: FontWeight.w900),
                                const SizedBox(
                                  height: 5,
                                ),
                                const AppTextStyle(
                                    textName:
                                        'Please subscribe to Small Biz Social to comment and post easily. The monthly fee is \$8 per month and you will never have to pay additional advertisement fees.',
                                    textColor: primaryTextColor,
                                    textSize: 12,
                                    textWeight: FontWeight.w400),
                                // text Form Fields
                                Consumer<SubscriptionSetupProvider>(
                                  builder: (context, sProvider, child) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          top: 24, right: 48),
                                      child: Form(
                                        key: sProvider.formState,
                                        child: Column(
                                          children: [
                                            FieldText(
                                              controller:
                                                  sProvider.firstNameController,
                                              labelText: 'First Name',
                                              errorText:
                                                  'Please Enter your first name',
                                              validater: (p0) {
                                                if (p0!.isEmpty) {
                                                  return 'Please Enter your first name';
                                                }
                                                return null;
                                              },
                                            ),
                                            FieldText(
                                              controller:
                                                  sProvider.lastNameController,
                                              labelText: 'Last Name',
                                              errorText:
                                                  'Please Enter your last name',
                                              validater: (p0) {
                                                if (p0!.isEmpty) {
                                                  return 'Please Enter your last name';
                                                }
                                                return null;
                                              },
                                            ),
                                            FieldText(
                                              controller: sProvider
                                                  .bussinessNameController,
                                              labelText: 'Bussiness Name',
                                              errorText:
                                                  'Please Entre business name',
                                              validater: (p0) {
                                                if (p0!.isEmpty) {
                                                  return 'Please Enter your business name';
                                                }
                                                return null;
                                              },
                                            ),
                                            FieldText(
                                              controller: sProvider
                                                  .businessLinkController,
                                              labelText: 'Bussiness Link',
                                              errorText:
                                                  'Please Entre your business link',
                                              validater: (p0) {
                                                if (p0!.isEmpty) {
                                                  return 'Please Enter your business link';
                                                }
                                                if (!p0.contains('http://') &&
                                                    !p0.contains('https://')) {
                                                  return 'Please Enter valid business link';
                                                }
                                                return null;
                                              },
                                            ),
                                            FieldText(
                                              controller:
                                                  sProvider.einNumberController,
                                              obscureText: true,
                                              labelText: 'EIN Number',
                                              errorText:
                                                  'Please Enter EIN Number',
                                              validater: (p0) {
                                                if (p0!.isEmpty) {
                                                  return 'Please Enter EIN Number';
                                                }
                                                if (p0.length < 9) {
                                                  return 'Please Enter valid EIN Number';
                                                }
                                                return null;
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                Consumer<SubscriptionSetupProvider>(
                                  builder: (context, sProvider, child) {
                                    return GestureContainer(
                                        containerName: 'Pay \$8',
                                        containerColor:
                                            sProvider.isChecked == false
                                                ? Colors.grey
                                                : buttonColor,
                                        isLoading: sProvider.isLoading ||
                                            provider.isLoading,
                                        onTap: () {
                                          if (sProvider.formState.currentState!
                                              .validate()) {
                                            sProvider.createBussiness(
                                                firstName: sProvider
                                                    .firstNameController.text,
                                                lastName: sProvider
                                                    .lastNameController.text,
                                                uid: Apis.auth.currentUser!.uid,
                                                bussinessName: sProvider
                                                    .bussinessNameController
                                                    .text,
                                                businessLink: sProvider
                                                    .businessLinkController
                                                    .text,
                                                einNumber: sProvider
                                                    .einNumberController.text,
                                                context: context);
                                          }
                                          if (sProvider.isChecked == false) {
                                            WarningHelper.showWarningDialog(
                                                context,
                                                'Error',
                                                'Please agree with terms and conditions');
                                          }
                                          if (sProvider.isChecked == true &&
                                              sProvider.formState.currentState!
                                                  .validate()) {
                                            provider.makePayment(
                                                amount: '8',
                                                currency: 'USD',
                                                context: context);
                                          }
                                        });
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 22),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Consumer<SubscriptionSetupProvider>(
                                        builder: (context, sProvider, child) {
                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            child: SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: Checkbox(
                                                value: sProvider.isChecked,
                                                onChanged: (newValue) {
                                                  sProvider.changeIsChecked(
                                                      newValue!);
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'I agree with ',
                                              style: GoogleFonts.inter(
                                                  color: Colors.black,
                                                  fontSize: 11),
                                            ),
                                            TextSpan(
                                              text: 'Terms',
                                              style: GoogleFonts.inter(
                                                  color: Colors.blue,
                                                  fontSize: 11),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  _launchUrl(_termsUrl);
                                                },
                                            ),
                                            TextSpan(
                                              text: ' and ',
                                              style: GoogleFonts.inter(
                                                  color: Colors.black,
                                                  fontSize: 11),
                                            ),
                                            TextSpan(
                                              text: 'Privacy',
                                              style: GoogleFonts.inter(
                                                  color: Colors.blue,
                                                  fontSize: 11),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  _launchUrl(_privacyUrl);
                                                },
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                // if the user is new only show that text
                                if (isNewUser == true)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 5),
                                    child: Center(
                                      child: TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pushReplacementNamed(
                                                    ProfilePercentage
                                                        .routeName);
                                          },
                                          child: Text(
                                            'Not Now',
                                            style: GoogleFonts.dmSans(
                                                fontSize: 24,
                                                color: primaryPinkColor,
                                                fontWeight: FontWeight.w600),
                                          )),
                                    ),
                                  ),
                              ],
                            )
                          : Center(
                              child: Container(
                                height: 460.0,
                                width: 320.0,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(
                                    top: 20, bottom: 20, left: 21, right: 21),
                                decoration: BoxDecoration(
                                  color: scaffoldColor,
                                  borderRadius: BorderRadius.circular(37.0),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        height: 137,
                                        width: 171,
                                        child: Image.asset(
                                          Images.alertEmoji,
                                        )),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Woo hoo!!',
                                      style: GoogleFonts.dmSans(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10,
                                          bottom: 10,
                                          left: 15,
                                          right: 15),
                                      child: Text(
                                        'Congrats! You have successfully subscribed to Small Biz Social! Make your first post now!',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.dmSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: primaryTextColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                ),
                // if the user is new to app
                if (isNewUser == true)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppTextStyle(
                            textName: 'Already have an account?',
                            textColor: primaryTextColor,
                            textSize: 14,
                            textWeight: FontWeight.w700),
                        TextButton(
                            onPressed: () {},
                            child: const AppTextStyle(
                                textName: 'Sign in',
                                textColor: Colors.blue,
                                textSize: 14,
                                textWeight: FontWeight.w700)),
                      ],
                    ),
                  )
              ],
            ),
          )),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
