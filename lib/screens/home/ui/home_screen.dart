import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/helper/alert_dialouge.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/helper/images_strings.dart';
import 'package:smallbiz/helper/text_style.dart';
import 'package:smallbiz/models/post_model.dart';
import 'package:smallbiz/screens/home/home_screen_widgets/pop_up_menue.dart';
import 'package:smallbiz/screens/home/home_screen_widgets/post_container_des.dart';
import 'package:smallbiz/screens/home/home_screen_widgets/search_form_field.dart';
import 'package:smallbiz/screens/home/provider/create_post_screen_provider.dart';
import 'package:smallbiz/screens/home/provider/home_screen_provider.dart';
import 'package:smallbiz/screens/home/ui/post_screen.dart';
import 'package:smallbiz/screens/splash_screen/providers/splash_screen_provider.dart';
import 'package:smallbiz/screens/users_chat/provider/chat_screen_provider.dart';
import 'package:smallbiz/utils/colors.dart';
import 'package:smallbiz/widgets/profile_avatar.dart';
import 'package:upgrader/upgrader.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  static const routeName = '/home-screen';

  final searchController = TextEditingController();
  final postController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<HomeScreenProvider>(context, listen: false);
    provider.initialize();
    // check if the user come from link
    Provider.of<HomeScreenProvider>(context, listen: false)
        .checkUserLink(context);
    // navigator key for navigation
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    // check if the user is connected to the internet
    var internetCheckProvider =
        Provider.of<InternetConnectionProvider>(context, listen: false);
    //check if the user is online
    Provider.of<ChatScreenProvider>(context, listen: false)
        .checkUserOnlineStatus();
    provider.get10PostsAtEach();
    var createPostProvider = Provider.of<CreatePostScreenProvider>(context);
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
        child: UpgradeAlert(
          navigatorKey: navigatorKey,
          upgrader: Upgrader(
            dialogStyle: UpgradeDialogStyle.cupertino,
            canDismissDialog: false,
            showIgnore: false,
            showLater: false,
            debugLogging: false,
          ),
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
                                      color: buttonColor,
                                      shape: BoxShape.circle),
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
                  Container(
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
                                if (value.isEmpty) return;
                                postController.text = value;
                                Apis.createPost(Apis.userDetail.firstName,
                                        value, PostType.text, value)
                                    .then((value) {
                                  provider.refreshPostList();
                                  postController.clear();
                                });
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
                  ),
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
                  Expanded(
                    child: Consumer<HomeScreenProvider>(
                        builder: (context, postProvider, child) {
                      return RefreshIndicator(
                        backgroundColor: white,
                        triggerMode: RefreshIndicatorTriggerMode.onEdge,
                        edgeOffset: 10,
                        color: buttonColor,
                        notificationPredicate: (notification) {
                          return notification.depth == 0;
                        },
                        onRefresh: () async {
                          internetCheckProvider.checkInternetConnection();
                          if (!internetCheckProvider.isConnected) {
                            internetCheckProvider.internetDialouge(
                                context, true);
                          }
                          await provider
                              .checkBeforeSubscription()
                              .then((value) {
                            if (value == true) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialouge(
                                      buttonText: 'Done',
                                      details:
                                          'Embrace the magic of every moment. Your subscription journey has been incredible, and in just few days, a new chapter begins. Renew your adventure, unlock more possibilities, and continue to thrive! 🌟🚀 #SubscriptionRenewal #CountdownToRenewal #StayInspired',
                                      image: Images.sadImage,
                                      message: 'Warning!',
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      });
                                },
                              );
                              debugPrint('subscription value $value');
                            } else {
                              debugPrint('subscription value $value');
                            }
                          });
                          return postProvider.refreshPostList();
                        },
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: provider.isSearching
                              ? provider.searchList.length
                              : postProvider.getPostList.length +
                                  1, // Add one for the loading indicator or message
                          itemBuilder: (context, index) {
                            if (index == postProvider.getPostList.length) {
                              // We've reached the end of the list. Show a loading indicator or message.
                              return Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  children: [
                                    SizedBox(
                                        height: 130,
                                        width: 130,
                                        child: Image.asset(Images.sadImage)),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Center(
                                        child: AppTextStyle(
                                            textName:
                                                'There is always more to watch',
                                            textColor: primaryTextColor,
                                            textSize: 23,
                                            textWeight: FontWeight.w300)),
                                  ],
                                ),
                              );
                            }
                            if (index == postProvider.getPostList.length - 1) {
                              postProvider.get10PostsAtEach();
                            }
                            return InkWell(
                              onTap: () {
                                PersistentNavBarNavigator.pushNewScreen(context,
                                    screen: PostScreen(
                                      data: postProvider.getPostList[index],
                                    ));
                              },
                              child: PostContainer(
                                data: provider.isSearching
                                    ? provider.searchList[index]
                                    : postProvider.getPostList[index],
                                isHomeScreen: true,
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
