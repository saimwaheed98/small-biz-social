import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/helper/text_style.dart';
import 'package:smallbiz/screens/home/provider/home_screen_provider.dart';
import 'package:smallbiz/screens/home/ui/post_screen.dart';
import 'package:smallbiz/helper/images_strings.dart';
import 'package:smallbiz/helper/alert_dialouge.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:smallbiz/screens/home/home_screen_widgets/post_container_des.dart';
import 'package:smallbiz/screens/splash_screen/providers/splash_screen_provider.dart';
import 'package:smallbiz/utils/colors.dart';

class PostList extends StatefulWidget {
  const PostList({super.key});

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  @override
  void initState() {
    Provider.of<HomeScreenProvider>(context, listen: false).get10PostsAtEach();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // check if the user is connected to the internet
    var internetCheckProvider =
        Provider.of<InternetConnectionProvider>(context, listen: false);
    return Expanded(
      child: Consumer<HomeScreenProvider>(builder: (context, provider, child) {
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
              internetCheckProvider.internetDialouge(context, true);
            }
            await provider.checkBeforeSubscription().then((value) {
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
            return provider.refreshPostList();
          },
          child: ListView.builder(
            physics: provider.isLoading
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            itemCount: provider.isSearching
                ? provider.searchList.length
                : provider.getPostList.length +
                    1, // Add one for the loading indicator or message
            itemBuilder: (context, index) {
              if (index == provider.getPostList.length) {
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
                              textName: 'There is always more to watch',
                              textColor: primaryTextColor,
                              textSize: 23,
                              textWeight: FontWeight.w300)),
                    ],
                  ),
                );
              }
              if (index == provider.getPostList.length - 1) {
                provider.get10PostsAtEach();
              }
              return InkWell(
                onTap: () {
                  PersistentNavBarNavigator.pushNewScreen(context,
                      screen: PostScreen(
                        data: provider.getPostList[index],
                        index: index,
                      ));
                },
                child: PostContainer(
                  data: provider.isSearching
                      ? provider.searchList[index]
                      : provider.getPostList[index],
                  index: index,
                  isHomeScreen: true,
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
