import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/helper/images_strings.dart';
import 'package:smallbiz/helper/shimmer_effect.dart';
import 'package:smallbiz/helper/text_style.dart';
import 'package:smallbiz/helper/warning_helper.dart';
import 'package:smallbiz/models/post_model.dart';
import 'package:smallbiz/referal_link/create_link_post.dart';
import 'package:smallbiz/screens/home/home_screen_widgets/action_containers.dart';
import 'package:smallbiz/screens/home/home_screen_widgets/like_counter_containers.dart';
import 'package:smallbiz/screens/home/provider/home_screen_provider.dart';
import 'package:smallbiz/screens/home/ui/post_screen.dart';
import 'package:smallbiz/screens/user_profile/ui/user_profile_screen.dart';
import 'package:smallbiz/screens/users_chat/user_chat_widgets/chat_container.dart';
import 'package:smallbiz/utils/colors.dart';
import 'package:smallbiz/utils/date_time.dart';
import 'package:smallbiz/widgets/video_player_internet.dart';

class PostContainer extends StatelessWidget {
  const PostContainer(
      {super.key, required this.data, required this.isHomeScreen});
  final PostModel data;
  final bool isHomeScreen;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
            color: postContainerColor, borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(
                        height: 50,
                        width: 50,
                      ),
                      InkWell(
                        onTap: () {
                          PersistentNavBarNavigator.pushDynamicScreen(context,
                              screen: MaterialPageRoute(
                                builder: (context) => UserProfile(
                                  postData: data,
                                  isUser: false,
                                ),
                              ),
                              withNavBar: true);
                        },
                        child: SizedBox(
                          height: 45,
                          width: 45,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(data.profileImage),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 1,
                        right: 1,
                        child: Container(
                            height: 25,
                            width: 25,
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xffFFCBE5)),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              backgroundImage: NetworkImage(data.profileImage),
                            )),
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 25,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Row(
                          children: [
                            AppTextStyle(
                              textName: data.postTitle,
                              textColor: Colors.black,
                              textSize: 16,
                              textWeight: FontWeight.w600,
                            ),
                            const Spacer(),

                            // show the pop menue for the post
                            PopupMenu(postData: data),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          AppTextStyle(
                              textName: '${data.username}.  ',
                              textColor: primaryTextColor,
                              textSize: 12,
                              textWeight: FontWeight.w500),
                          AppTextStyle(
                              textName:
                                  '${MyDateUtil().formatTimestampToDaysAgo(data.publishDate)}. ',
                              textColor: primaryTextColor,
                              textSize: 12,
                              textWeight: FontWeight.w500),
                          const Icon(Icons.public,
                              color: primaryTextColor, size: 12)
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          alignment: Alignment.center,
                          height: 17,
                          width: 58,
                          decoration: BoxDecoration(
                              color: buttonColor.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(5)),
                          child: const AppTextStyle(
                              textName: 'Subscriber',
                              textColor: primaryTextColor,
                              textSize: 10,
                              textWeight: FontWeight.w500),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 10, left: 16, right: 16, bottom: 10),
              child: ReadMoreText(
                data.description,
                trimLines: 2,
                style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: const Color(0xff4C4C4C)),
                colorClickableText: Colors.pink,
                trimMode: TrimMode.Line,
                trimCollapsedText: 'Show more',
                trimExpandedText: 'Show less',
                lessStyle: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: Colors.blue),
                moreStyle: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: Colors.blue),
              ),
            ),
            if (data.postType == PostType.image)
              InkWell(
                onTap: () {
                  PersistentNavBarNavigator.pushNewScreen(context,
                      withNavBar: false,
                      screen: ImageOpenar(imageUrl: data.postData));
                },
                child: Container(
                    height: 360,
                    width: double.infinity,
                    decoration: const BoxDecoration(color: Colors.white),
                    child: CachedNetworkImage(
                      imageUrl: data.postData,
                      fit: BoxFit.cover,
                      placeholder: (context, url) {
                        return const ImageLoading(
                          height: 360,
                          width: double.infinity,
                        );
                      },
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    )),
              ),
            if (data.postType == PostType.text)
              Container(
                height: 360,
                width: double.infinity,
                alignment: Alignment.center,
                color: Colors.white,
                child: AppTextStyle(
                    textName: data.postData,
                    textColor: primaryTextColor,
                    textSize: 20,
                    textWeight: FontWeight.w400),
              ),
            if (data.postType == PostType.video)
              VideoPlayerItem(postData: data),
            if (data.stars.isNotEmpty ||
                data.likes.isNotEmpty ||
                data.comments.isNotEmpty)
              if (isHomeScreen == true)
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 10, left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (data.likes.isNotEmpty)
                        LikeCounterContainer(
                          containerImage: Images.likeImage,
                          containerText: '${data.likes.length}',
                        ),
                      if (data.likes.isNotEmpty)
                        LikeCounterContainer(
                          containerImage: Images.heartImage,
                          containerText: '${data.likes.length}',
                        ),
                      if (data.stars.isNotEmpty)
                        LikeCounterContainer(
                          containerImage: Images.starImage,
                          containerText: '${data.stars.length}',
                        ),
                      if (data.comments.isNotEmpty)
                        LikeCounterContainer(
                          containerImage: Images.commentImage,
                          containerText: '${data.comments.length}',
                        )
                    ],
                  ),
                ),
            Container(
              height: 50,
              decoration: BoxDecoration(
                  border: Border.symmetric(
                      horizontal: BorderSide(
                          color: Colors.grey.withOpacity(0.5), width: 1))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  LikeButton(data: data),
                  StarButton(data: data),
                  InkWell(
                    onTap: () {
                      PersistentNavBarNavigator.pushDynamicScreen(context,
                          screen: MaterialPageRoute(
                            builder: (context) => PostScreen(data: data),
                          ),
                          withNavBar: true);
                    },
                    child: SizedBox(
                      height: 70,
                      child: Row(
                        children: [
                          SizedBox(
                              height: 24,
                              width: 24,
                              child: Image.asset(Images.comment)),
                          const SizedBox(
                            width: 5,
                          ),
                          const AppTextStyle(
                              textName: 'Comment',
                              textColor: primaryTextColor,
                              textSize: 11,
                              textWeight: FontWeight.w500),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      DeepLinkPostService().createReferLink(data).then((value) {
                        Share.share(value);
                      });
                    },
                    child: SizedBox(
                      height: 70,
                      child: Row(
                        children: [
                          SizedBox(
                              height: 24,
                              width: 24,
                              child: Image.asset(Images.share)),
                          const SizedBox(
                            width: 5,
                          ),
                          const AppTextStyle(
                              textName: 'Share',
                              textColor: primaryTextColor,
                              textSize: 11,
                              textWeight: FontWeight.w500),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PopupMenu extends StatefulWidget {
  final PostModel postData;
  const PopupMenu({super.key, required this.postData});

  @override
  // ignore: library_private_types_in_public_api
  _PopupMenu createState() => _PopupMenu();
}

class _PopupMenu extends State<PopupMenu> {
  final GlobalKey _popupKey = GlobalKey();

  void _showPopupMenu() {
    final RenderBox popupRenderBox =
        _popupKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        popupRenderBox.localToGlobal(Offset.zero, ancestor: overlay),
        popupRenderBox.localToGlobal(
            popupRenderBox.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    var provider = Provider.of<HomeScreenProvider>(context, listen: false);

    showMenu(
      context: context,
      position: position,
      color: const Color(0xffFFD2D4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7),
      ),
      constraints: const BoxConstraints(maxWidth: double.infinity),
      items: [
        if (widget.postData.uid != Apis.userDetail.uid)
          PopupMenuItem(
              value: 'post_hided',
              child: Row(
                children: [
                  Container(
                    height: 30,
                    width: 30,
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(
                      color: Color(0xffFFBEC1),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.delete, color: buttonColor, size: 18),
                  ),
                  const SizedBox(width: 7),
                  const AppTextStyle(
                    textName: 'Hide Post',
                    textColor: Colors.black,
                    textSize: 16,
                    textWeight: FontWeight.w600,
                  ),
                ],
              ),
              onTap: () {
                provider.removePost(widget.postData);
                WarningHelper.toastMessage('Post Hided');
              }),
        PopupMenuItem(
          value: 'link_copied',
          child: Row(
            children: [
              Container(
                  height: 30,
                  width: 30,
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                      color: Color(0xffFFBEC1), shape: BoxShape.circle),
                  child: const Icon(Icons.copy,
                      color: Color(0xffFF7D83), size: 18)),
              const SizedBox(
                width: 7,
              ),
              const AppTextStyle(
                  textName: 'Copy Link',
                  textColor: Colors.black,
                  textSize: 16,
                  textWeight: FontWeight.w600)
            ],
          ),
          onTap: () {
            DeepLinkPostService()
                .createReferLink(widget.postData)
                .then((value) {
              Clipboard.setData(ClipboardData(text: value)).then((value) {
                WarningHelper.toastMessage('Link Copied');
              });
            });
          },
        ),
        if (widget.postData.uid == Apis.userDetail.uid)
          PopupMenuItem(
            value: 'Delete_post',
            child: Row(
              children: [
                Container(
                    height: 30,
                    width: 30,
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(
                        color: Color(0xffFFBEC1), shape: BoxShape.circle),
                    child: const Icon(Icons.delete_forever_rounded,
                        color: Color(0xffFF7D83), size: 18)),
                const SizedBox(
                  width: 7,
                ),
                const AppTextStyle(
                    textName: 'Delete Post',
                    textColor: Colors.black,
                    textSize: 16,
                    textWeight: FontWeight.w600)
              ],
            ),
            onTap: () {
              Apis.deletePost(widget.postData).then((value) {
                WarningHelper.toastMessage('Post Deleted');
              });
            },
          ),
        // Add more PopupMenuItems as needed
      ],
    ).then((value) {
      if (value != null) {
        // Perform actions based on selected value if needed
        debugPrint('Selected: $value');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: _popupKey,
      onTap: _showPopupMenu,
      child: const Icon(Icons.more_horiz_rounded),
    );
  }
}
