import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/helper/text_style.dart';
import 'package:smallbiz/screens/create_account/provider/profile_picture_provider.dart';
import 'package:smallbiz/screens/subscription_setup/ui/subscription_setup_screen.dart';
import 'package:smallbiz/utils/colors.dart';
import 'package:smallbiz/widgets/gesture_container.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileImage extends StatelessWidget {
  final File image;
  ProfileImage({
    super.key,
    required this.image,
  });
  static const routeName = '/profile-image';
  final Uri _termsUrl = Uri.parse(
      'https://firebasestorage.googleapis.com/v0/b/small-biz-social-30ff3.appspot.com/o/Terms.pdf?alt=media&token=c8b6546b-0e43-4792-ae89-722fe41fc8ce');
  final Uri _privacyUrl = Uri.parse(
      'https://firebasestorage.googleapis.com/v0/b/small-biz-social-30ff3.appspot.com/o/Privacy%20Policy.pdf?alt=media&token=d42e769f-3efd-40a9-b435-93974d6bcb29');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: scaffoldColor,
        body: Padding(
          padding:
              const EdgeInsets.only(top: 25, left: 16, right: 16, bottom: 16),
          child: Column(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: primaryPinkColor,
                          )),
                    ),
                    const AppTextStyle(
                        textName: 'Upload Profile Picture',
                        textColor: Colors.black,
                        textSize: 24,
                        textWeight: FontWeight.w900),
                    const SizedBox(
                      height: 5,
                    ),
                    const AppTextStyle(
                        textName: 'Please upload a new profile pic',
                        textColor: primaryTextColor,
                        textSize: 12,
                        textWeight: FontWeight.w400),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 72),
                      child: Center(
                        child: Container(
                            height: 239,
                            width: 239,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(120),
                                color: Colors.grey[300]),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(120),
                                child: Image.file(
                                  image,
                                  fit: BoxFit.cover,
                                ))),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Consumer<ProfilePictureProvider>(
                      builder: (context, profilePicture, child) {
                        return GestureContainer(
                            containerName: 'Next',
                            containerColor: profilePicture.isChecked
                                ? buttonColor
                                : Colors.grey,
                            isLoading: profilePicture.isLoading,
                            onTap: () {
                              if (profilePicture.isChecked) {
                                profilePicture
                                    .updateProfilePicture(image)
                                    .then((value) {
                                  Navigator.pushNamed(
                                      context, SubscriptionSetup.routename);
                                });
                              }
                            });
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: SizedBox(
                              width: 16,
                              height: 16,
                              child: Consumer<ProfilePictureProvider>(
                                builder: (context, isCheck, child) {
                                  return Checkbox(
                                    value: isCheck.isChecked,
                                    onChanged: (newValue) {
                                      isCheck.setChecked(newValue!);
                                    },
                                  );
                                },
                              )),
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
                                    color: Colors.black, fontSize: 11),
                              ),
                              TextSpan(
                                text: 'Terms',
                                style: GoogleFonts.inter(
                                    color: Colors.blue, fontSize: 11),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _launchUrl(_termsUrl);
                                  },
                              ),
                              TextSpan(
                                text: ' and ',
                                style: GoogleFonts.inter(
                                    color: Colors.black, fontSize: 11),
                              ),
                              TextSpan(
                                text: 'Privacy',
                                style: GoogleFonts.inter(
                                    color: Colors.blue, fontSize: 11),
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
                  ],
                ),
              ),
              const Spacer(),
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
                      onPressed: () {},
                      child: const AppTextStyle(
                          textName: 'Sign in',
                          textColor: Colors.blue,
                          textSize: 14,
                          textWeight: FontWeight.w700)),
                ],
              )
            ],
          ),
        ));
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
