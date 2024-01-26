import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/helper/images_strings.dart';
import 'package:smallbiz/helper/shimmer_effect.dart';
import 'package:smallbiz/helper/text_style.dart';
import 'package:smallbiz/helper/warning_helper.dart';
import 'package:smallbiz/models/post_comment_model.dart';
import 'package:smallbiz/models/post_model.dart';
import 'package:smallbiz/models/user_detail_model.dart';
import 'package:smallbiz/referal_link/create_link.dart';
import 'package:smallbiz/screens/home/home_screen_widgets/post_container_des.dart';
import 'package:smallbiz/screens/user_profile/ui/profile_settings.dart';
import 'package:smallbiz/screens/users_chat/provider/chat_screen_provider.dart';
import 'package:smallbiz/screens/users_chat/ui/chat_screen.dart';
import 'package:smallbiz/utils/colors.dart';
import 'package:smallbiz/widgets/gesture_container.dart';

class UserProfile extends StatelessWidget {
  final UserDetail? user;
  final bool isUser;
  final PostModel? postData;
  final PostCommentModel? commentData;
  UserProfile(
      {super.key,
      this.user,
      this.isUser = true,
      this.postData,
      this.commentData});

  final List<PostModel> postList = [];

  static const routename = '/userProfile';

  @override
  Widget build(BuildContext context) {
    var linkProvider = Provider.of<DeepLinkService>(context);
    Provider.of<ChatScreenProvider>(context, listen: false)
        .checkUserOnlineStatus();
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: white,
        title: const AppTextStyle(
            textName: 'Profile',
            textColor: black,
            textSize: 16,
            textWeight: FontWeight.w600),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_outlined,
              color: Color(0xff610030),
            )),
      ),
      body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                color: postContainerColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isUser)
                      Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                              onPressed: () {
                                PersistentNavBarNavigator.pushNewScreen(context,
                                    screen: const ProfileSetting(),
                                    withNavBar: false);
                              },
                              icon: const Icon(
                                Icons.settings,
                                color: primaryTextColor,
                              ))),
                    CachedNetworkImage(
                      imageUrl: isUser == true
                          ? Apis.userDetail.profilePicture
                          : user?.profilePicture ??
                              postData?.profileImage ??
                              commentData?.userImage ??
                              '',
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(),
                          AppTextStyle(
                              textName: isUser == true
                                  ? Apis.userDetail.firstName
                                  : user?.firstName ??
                                      postData?.username ??
                                      commentData?.userName ??
                                      '',
                              textColor: black,
                              textSize: 24,
                              textWeight: FontWeight.w600),
                          if (Apis.userDetail.subscription == true)
                            SvgPicture.asset(Images.verified),
                          if (Apis.userDetail.subscription == false)
                            const SizedBox(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(),
                          if (isUser == true)
                            Padding(
                              padding: const EdgeInsets.only(left: 70),
                              child: InkWell(
                                onTap: () async {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return BioUpdateDialouge(
                                            user: Apis.userDetail);
                                      });
                                },
                                child: Container(
                                    height: 40,
                                    width: 120,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: buttonColor),
                                    child: const AppTextStyle(
                                        textName: 'Add Bio',
                                        textColor: black,
                                        textSize: 20,
                                        textWeight: FontWeight.w400)),
                              ),
                            ),
                          if (isUser == false)
                            Padding(
                              padding: const EdgeInsets.only(left: 70),
                              child: InkWell(
                                onTap: () async {
                                  PersistentNavBarNavigator.pushNewScreen(
                                      context,
                                      screen: ChatScreen(
                                        isClickAble: true,
                                        user: user,
                                        postData: postData,
                                        commentUser: commentData,
                                      ),
                                      withNavBar: false);
                                },
                                child: Container(
                                    height: 40,
                                    width: 120,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: buttonColor),
                                    child: Text(
                                      'Message ${user?.firstName ?? postData?.username ?? commentData?.userName ?? ''}',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.dmSans(
                                          fontSize: isUser == false ? 14 : 20,
                                          color: black,
                                          fontWeight: FontWeight.w400),
                                    )),
                              ),
                            ),
                          InkWell(
                            onTap: () {
                              WarningHelper.showProgressDialog(context);
                              linkProvider
                                  .createReferLink(
                                isUser == true
                                    ? Apis.userDetail.uid
                                    : user?.uid ??
                                        postData?.uid ??
                                        commentData?.fromId ??
                                        '',
                              )
                                  .then((value) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ShowQrDialouge(
                                      qrData: value,
                                      user: user,
                                      isUser: isUser,
                                      postData: postData,
                                      commentData: commentData,
                                    );
                                  },
                                );
                              });
                            },
                            child: Container(
                                height: 40,
                                width: 70,
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: buttonColor),
                                child: Image.asset(Images.shareImage)),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(Icons.public,
                                color: Color(0xff303038), size: 16),
                            const SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: AppTextStyle(
                                  textName: isUser == true
                                      ? Apis.userDetail.bio
                                      : user != null
                                          ? user!.bio
                                          : postData?.postTitle ?? '',
                                  textColor: primaryTextColor,
                                  textSize: 14,
                                  textWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              StreamBuilder(
                stream: isUser == true
                    ? Apis.getMyPosts(user: Apis.userDetail)
                    : user != null
                        ? Apis.getMyPosts(user: user)
                        : postData != null
                            ? Apis.getMyPosts(postUser: postData)
                            : Apis.getMyPosts(commentUser: commentData),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.docs.isEmpty) {
                      return const AppTextStyle(
                          textName: 'No Posts Created Yet',
                          textColor: primaryTextColor,
                          textSize: 16,
                          textWeight: FontWeight.bold);
                    }
                    final data = snapshot.data?.docs;
                    final list = data
                            ?.map((e) => PostModel.fromJson(e.data()))
                            .toList() ??
                        [];
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        // final data = snapshot.data!.docs[index].data();
                        return PostContainer(
                          data: list[index],
                          isHomeScreen: true,
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              )
            ],
          )),
    );
  }
}

// add bio dialog

class BioUpdateDialouge extends StatelessWidget {
  final UserDetail user;
  const BioUpdateDialouge({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    String updatedMsg = user.bio;
    return AlertDialog(
      backgroundColor: scaffoldColor,
      shadowColor: black.withOpacity(0.2),
      contentPadding:
          const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      //title
      title: const Row(
        children: [
          Icon(
            Icons.edit,
            color: Colors.blue,
            size: 22,
          ),
          Gap(10),
          AppTextStyle(
              textName: 'Update bio',
              textColor: primaryTextColor,
              textSize: 16,
              textWeight: FontWeight.w600)
        ],
      ),
      //content
      content: TextFormField(
        initialValue: updatedMsg,
        autofocus: true,
        maxLines: null,
        onChanged: (value) => updatedMsg = value,
        decoration: InputDecoration(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
      ),

      //actions
      actions: [
        //cancel button
        MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.actor(fontSize: 16, color: Colors.blue),
            )),
        //update button
        MaterialButton(
            onPressed: () {
              Navigator.pop(context);
              Apis.updateBio(updatedMsg);
            },
            child: Text(
              'Update',
              style: GoogleFonts.actor(color: Colors.blue, fontSize: 16),
            ))
      ],
    );
  }
}

// show dialog which show qr code

class ShowQrDialouge extends StatelessWidget {
  final UserDetail? user;
  final bool isUser;
  final PostModel? postData;
  final PostCommentModel? commentData;
  final String qrData;
  const ShowQrDialouge(
      {super.key,
      this.user,
      this.postData,
      this.commentData,
      required this.qrData,
      required this.isUser});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: scaffoldColor,
      shadowColor: black.withOpacity(0.2),
      contentPadding:
          const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      //title
      title: const Row(
        children: [
          Icon(
            Icons.qr_code_rounded,
            color: buttonColor,
            size: 22,
          ),
          Gap(10),
          AppTextStyle(
              textName: 'Scan QR Code',
              textColor: primaryTextColor,
              textSize: 16,
              textWeight: FontWeight.w600)
        ],
      ),
      //content
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 200,
            width: 200,
            child: PrettyQrView.data(
              data: qrData,
            ),
          ),
        ],
      ),
      //actions
      actions: [
        GestureContainer(
            containerName: 'Copy Link',
            onTap: () {
              Clipboard.setData(ClipboardData(text: qrData)).then((value) {
                WarningHelper.toastMessage('Link Copied');
                Share.share(qrData);
                Navigator.pop(context);
              });
            })
      ],
    );
  }
}
