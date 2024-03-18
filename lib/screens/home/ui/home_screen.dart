import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/helper/text_style.dart';
import 'package:smallbiz/helper/warning_helper.dart';
import 'package:smallbiz/models/post_model.dart';
import 'package:smallbiz/screens/home/home_screen_widgets/pop_up_menue.dart';
import 'package:smallbiz/screens/home/home_screen_widgets/post_list.dart';
import 'package:smallbiz/screens/home/home_screen_widgets/search_form_field.dart';
import 'package:smallbiz/screens/home/provider/create_post_screen_provider.dart';
import 'package:smallbiz/screens/home/provider/home_screen_provider.dart';
import 'package:smallbiz/screens/users_chat/provider/chat_screen_provider.dart';
import 'package:smallbiz/utils/colors.dart';
import 'package:smallbiz/widgets/profile_avatar.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  static const routeName = '/home-screen';

  final searchController = TextEditingController();
  final postController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //check if the user is online
    Provider.of<ChatScreenProvider>(context, listen: false)
        .checkUserOnlineStatus();
    var createPostProvider =
        Provider.of<CreatePostScreenProvider>(context, listen: false);
    debugPrint('home screen build');
    return WillPopScope(
      onWillPop: () {
        if (createPostProvider.isUploading) {
          Apis.updateActiveStatus(false);
          return Future.value(false);
        } else {
          Apis.updateActiveStatus(false);
          return Future.value(true);
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: scaffoldColor.withOpacity(0.9),
          body: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Column(
              children: [
                Consumer<HomeScreenProvider>(
                  builder: (context, provider, child) {
                    return Container(
                      height: 65,
                      color: const Color(0xffFFF2F9),
                      child: Row(
                        children: [
                          if (provider.isSearching == false)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: AppTextStyle(
                                  textName: 'Small Biz Social',
                                  textColor: primaryTextColor,
                                  textSize: 28,
                                  textWeight: FontWeight.w500),
                            ),
                          if (provider.isSearching == false) const Spacer(),
                          if (provider.isSearching == false)
                            InkWell(
                              onTap: () {
                                provider.searching(true);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height: 38,
                                width: 38,
                                decoration: const BoxDecoration(
                                    color: buttonColor, shape: BoxShape.circle),
                                child: SvgPicture.asset(
                                  'assets/icons/search_icon.svg',
                                  height: 15,
                                  width: 15,
                                  // ignore: deprecated_member_use
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          if (provider.isSearching == true)
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SearchField(
                                searchController: searchController,
                                onChanged: (searchValue) {
                                  if (searchValue.isNotEmpty) {
                                    provider.searching(true);
                                    provider.searchList.clear();
                                    for (var i in provider.getPostList) {
                                      if (i.postTitle
                                              .toLowerCase()
                                              .trim()
                                              .contains(searchValue
                                                  .toLowerCase()
                                                  .trim()) ||
                                          i.description
                                              .toLowerCase()
                                              .trim()
                                              .contains(searchValue
                                                  .toLowerCase()
                                                  .trim()) ||
                                          i.username
                                              .toLowerCase()
                                              .trim()
                                              .contains(searchValue
                                                  .toLowerCase()
                                                  .trim())) {
                                        provider.searchList.add(i);
                                      }
                                    }
                                  } else {
                                    provider.searching(false);
                                    provider.searchList.clear();
                                  }
                                },
                              ),
                            )),
                          const ProfileAvatar(),
                        ],
                      ),
                    );
                  },
                ),
                Consumer<HomeScreenProvider>(
                    builder: (context, provider, child) {
                  return Container(
                    color: const Color(0xffFFD2D4),
                    child: Row(
                      children: [
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 46,
                            child: TextFormField(
                              controller: postController,
                              onFieldSubmitted: (value) {
                                debugPrint('on field Submit $value');
                                if (value.isEmpty) {
                                  return;
                                } else if (Apis.userDetail.subscription ==
                                    true) {
                                  postController.text = value;
                                  Apis.createPost(Apis.userDetail.firstName,
                                          value, PostType.text, value)
                                      .then((value) {
                                    provider.refreshPostList();
                                    postController.clear();
                                  });
                                } else {
                                  WarningHelper.showWarningDialog(
                                      context,
                                      'Warning',
                                      'Please Subscribe to Small Biz Social');
                                }
                              },
                              style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                              decoration: InputDecoration(
                                  suffixIcon: const Padding(
                                    padding: EdgeInsets.all(5),
                                    child: PopupMenuCreatePost(),
                                  ),
                                  contentPadding: const EdgeInsets.all(10),
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'Create a post',
                                  hintStyle: GoogleFonts.dmSans(
                                    fontSize: 10,
                                    color: primaryTextColor,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide.none)),
                            ),
                          ),
                        )),
                      ],
                    ),
                  );
                }),
                Consumer<CreatePostScreenProvider>(
                  builder: (context, createPostProvider, child) {
                    return createPostProvider.isUploading
                        ? Container(
                            height: 40,
                            width: double.infinity,
                            color: Colors.white,
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  AppTextStyle(
                                    textName:
                                        'Please Stay in App While Uploading Post',
                                    textColor: black,
                                    textSize: 13,
                                    textWeight: FontWeight.bold,
                                  ),
                                  SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: CircularProgressIndicator(
                                      color: buttonColor,
                                      backgroundColor: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(); // Return an empty SizedBox if not uploading
                  },
                ),
                //list of users posts
                const PostList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
