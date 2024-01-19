import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/helper/image_picker.dart';
import 'package:smallbiz/helper/shimmer_effect.dart';
import 'package:smallbiz/helper/text_style.dart';
import 'package:smallbiz/helper/warning_helper.dart';
import 'package:smallbiz/screens/create_account/ui/create_account_screen.dart';
import 'package:smallbiz/screens/user_profile/profle_settings_widgets/text_field.dart';
import 'package:smallbiz/screens/user_profile/provider/profile_setting_provider.dart';
import 'package:smallbiz/utils/colors.dart';
import 'package:smallbiz/utils/date_time.dart';
import 'package:smallbiz/widgets/gesture_container.dart';

class ProfileSetting extends StatelessWidget {
  static const routeName = '/profile-setting';
  const ProfileSetting({super.key});

  @override
  Widget build(BuildContext context) {
    // get the source of provider
    var imageProvider =
        Provider.of<ImagePickerProvider>(context, listen: false);
    var provider = Provider.of<ProfileSettingProvider>(context, listen: false);
    // initialize the value of the controllers to respect with userDetails
    provider.firstNameController.text = Apis.userDetail.firstName;
    provider.lastNameController.text = Apis.userDetail.lastName;
    provider.bioController.text = Apis.userDetail.bio;
    provider.controller.text = Apis.userDetail.subscription == true
        ? 'You are subscribed'
        : 'You are not subscribed';

    // then build the screen
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: white,
        title: const AppTextStyle(
            textName: 'Profile Settings',
            textColor: black,
            textSize: 16,
            textWeight: FontWeight.w600),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              imageProvider.setImage(null);
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_outlined,
              color: Color(0xff610030),
            )),
        actions: [
          IconButton(
              onPressed: () async {
                await Apis.updateActiveStatus(false);
                await Apis.auth.signOut().then((value) {
                  WarningHelper.showWarningDialog(
                      context, 'Sign Out', 'Signed Out Successfully');
                  PersistentNavBarNavigator.pushDynamicScreen(context,
                      screen: MaterialPageRoute(
                          builder: (context) => CreateAccount(),
                          fullscreenDialog: true),
                      withNavBar: false);
                });
              },
              icon: const Icon(
                Icons.logout_rounded,
                color: black,
              )),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Stack(
                  children: [
                    const SizedBox(
                      height: 140,
                      width: 140,
                    ),
                    imageProvider.image != null
                        ? Consumer(
                            builder: (context, value, child) {
                              return CircleAvatar(
                                radius: 70,
                                backgroundImage:
                                    FileImage(imageProvider.image!),
                              );
                            },
                          )
                        : CachedNetworkImage(
                            imageUrl: Apis.userDetail.profilePicture,
                            imageBuilder: (context, imageProvider) => Container(
                              height: 140,
                              width: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    const AvatarLoading(radius: 70),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.5)),
                        child: IconButton(
                          onPressed: () {
                            imageProvider.getImage(
                                context, ImageSource.gallery);
                          },
                          icon: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const AppTextStyle(
                    textName: 'Account Details',
                    textColor: primaryTextColor,
                    textSize: 18,
                    textWeight: FontWeight.bold),
                const SizedBox(
                  height: 10,
                ),
                Form(
                  key: provider.formKey,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 70),
                    child: Column(
                      children: [
                        ProfileSettingTextField(
                          lableText: 'Firstname',
                          controller: provider.firstNameController,
                          maxLength: 20,
                          onSubmitted: (value) {
                            provider.onControllerChange();
                            debugPrint('value ${provider.isControllerChange}');
                          },
                        ),
                        ProfileSettingTextField(
                          lableText: 'Lastname',
                          controller: provider.lastNameController,
                          maxLength: 15,
                          onSubmitted: (value) {
                            provider.onControllerChange();
                            debugPrint('value ${provider.isControllerChange}');
                          },
                        ),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 150),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              maxLines: null,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(12),
                                fillColor: white,
                                filled: true,
                                labelText: 'Bio',
                                labelStyle: GoogleFonts.dmSans(
                                  color: primaryTextColor,
                                  fontSize: 15,
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide.none),
                                counterText: '',
                              ),
                              controller: provider.bioController,
                              keyboardType: TextInputType.name,
                              onFieldSubmitted: (value) {
                                provider.onControllerChange();
                                debugPrint(
                                    'value ${provider.isControllerChange}');
                              },
                            ),
                          ),
                        ),
                        ProfileSettingTextField(
                          lableText: 'Subscription status',
                          controller: provider.controller,
                          canEdit: false,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  color: white,
                  thickness: 2,
                  indent: 20,
                  endIndent: 20,
                ),
                const SizedBox(
                  height: 5,
                ),
                // Inside the build method or the widget tree
// Wrap the 'Consumer' with a 'Visibility' widget to conditionally show/hide the button
                Consumer<ProfileSettingProvider>(
                  builder: (context, provider, child) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureContainer(
                        isLoading: provider.isLoading,
                        containerName: 'Update',
                        onTap: () {
                          if (provider.isControllerChange) {
                            provider.updateDetails().then((value) {
                              Apis.userDetail.firstName =
                                  provider.firstNameController.text;
                              Apis.userDetail.lastName =
                                  provider.lastNameController.text;
                              Apis.userDetail.bio = provider.bioController.text;
                              if (imageProvider.image != null) {
                                provider
                                    .updateProfilePicture(imageProvider.image!)
                                    .then((value) {
                                  Apis.userDetail.profilePicture =
                                      provider.imageUrl!;
                                  WarningHelper.toastMessage(
                                      'Profile updated successfully');
                                });
                                imageProvider.setImage(null);
                              }
                            });
                            WarningHelper.toastMessage(
                                'Profile updated successfully');
                          } else if (imageProvider.image != null) {
                            provider.updateProfilePicture(imageProvider.image!);
                            Apis.userDetail.profilePicture = provider.imageUrl!;
                            WarningHelper.toastMessage(
                                'Profile updated successfully');
                            Apis.userDetail.profilePicture = provider.imageUrl!;
                            imageProvider.setImage(null);
                          } else {
                            WarningHelper.toastMessage(
                                'Please make some changes to update');
                          }
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
            const AppTextStyle(
                textName: 'Created At',
                textColor: primaryTextColor,
                textSize: 18,
                textWeight: FontWeight.bold),
            AppTextStyle(
                textName: MyDateUtil.getMessageTime(
                    context: context, time: Apis.userDetail.createdAt),
                textColor: primaryTextColor,
                textSize: 16,
                textWeight: FontWeight.w300),
          ],
        ),
      ),
    );
  }
}
