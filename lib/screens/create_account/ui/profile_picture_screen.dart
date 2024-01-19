import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/helper/images_strings.dart';
import 'package:smallbiz/helper/text_style.dart';
import 'package:smallbiz/screens/create_account/create_account_screen_widget/bottom_container.dart';
import 'package:smallbiz/screens/create_account/provider/profile_picture_provider.dart';
import 'package:smallbiz/screens/create_account/ui/profile_picture.dart';
import 'package:smallbiz/utils/colors.dart';
import 'package:smallbiz/widgets/gesture_container.dart';

class ProfilePicture extends StatelessWidget {
  const ProfilePicture({super.key});

  static const routeName = '/profile-picture';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: scaffoldColor,
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding:
              const EdgeInsets.only(top: 25, left: 16, right: 16, bottom: 16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
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
                          textName:
                              'Please upload a new profile pic',
                          textColor: primaryTextColor,
                          textSize: 12,
                          textWeight: FontWeight.w400),
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: SizedBox(
                            height: 337,
                            child: Image.asset(
                              Images.vectorProfile,
                              fit: BoxFit.cover,
                            )),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureContainer(
                          containerName: 'Upload Image',
                          onTap: () {
                            _showBottomSheet(context);
                          }),
                    ],
                  ),
                ),
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

  void _showBottomSheet(context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        enableDrag: false,
        isDismissible: false,
        context: context,
        builder: (context) {
          return SizedBox(
            height: 200,
            child: Column(
              children: [
                Consumer<ProfilePictureProvider>(
                  builder: (context, image, child) {
                    return BottomContainer(
                      containerName: 'Upload from gallery',
                      onPressed: () async {
                        image
                            .getProfileImage(ImageSource.gallery)!
                            .then((value) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileImage(
                                  image: image.profilePicture!,
                                ),
                              ));
                        });
                      },
                      radiusTop: const Radius.circular(10),
                      radiusBottom: const Radius.circular(0),
                      radiusLeft: const Radius.circular(10),
                      radiusRight: const Radius.circular(0),
                    );
                  },
                ),
                Consumer<ProfilePictureProvider>(
                  builder: (context, image, child) {
                    return BottomContainer(
                      containerName: 'Upload from camera',
                      onPressed: () async {
                        image
                            .getProfileImage(ImageSource.camera)!
                            .then((value) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileImage(
                                  image: image.profilePicture!,
                                ),
                              ));
                        });
                      },
                      radiusTop: const Radius.circular(0),
                      radiusBottom: const Radius.circular(10),
                      radiusLeft: const Radius.circular(0),
                      radiusRight: const Radius.circular(10),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: BottomContainer(
                    containerName: 'Cancel',
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    radiusTop: const Radius.circular(10),
                    radiusBottom: const Radius.circular(10),
                    radiusLeft: const Radius.circular(10),
                    radiusRight: const Radius.circular(10),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
