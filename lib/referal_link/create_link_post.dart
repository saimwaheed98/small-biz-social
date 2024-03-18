import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/models/post_model.dart';
import 'package:smallbiz/screens/home/ui/post_screen.dart';

class DeepLinkPostService {
  final dynamicLink = FirebaseDynamicLinks.instance;

  Future<String> createReferLink(PostModel postData) async {
    FirebaseDynamicLinks links = FirebaseDynamicLinks.instance;
    final DynamicLinkParameters dynamicLinkParameters = DynamicLinkParameters(
      uriPrefix: 'https://smallbizsocial.page.link',
      link:
          Uri.parse('https://smallbizsocial.page.link?post=${postData.postId}'),
      androidParameters: const AndroidParameters(
        packageName: 'com.social.smallbizsocial',
        minimumVersion: 1,
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.social.smallbizsocial',
        minimumVersion: '1',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: postData.profileImage,
        description: postData.postTitle,
        imageUrl: Uri.parse(postData.postData),
      ),
    );

    final shortLink = await links.buildShortLink(dynamicLinkParameters);
    return shortLink.shortUrl.toString();
  }

  void initDynamicLinks(BuildContext context) async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      final Uri? deepLink = dynamicLinkData.link;
      if (deepLink != null) {
        final queryParams = deepLink.queryParameters;
        final profileCode = queryParams['post'];
        if (profileCode != null) {
          Apis.firestore
              .collection('posts')
              .doc(profileCode)
              .get()
              .then((snapshot) {
            if (snapshot.exists) {
              final postData = PostModel.fromJson(snapshot.data()!);
              PersistentNavBarNavigator.pushNewScreen(context,
                  screen: PostScreen(
                    data: postData,
                    index: 0,
                  ));
            }
          });
        }
      }
    }).onError((error) {
      debugPrint('Dynamic Link Error: $error');
    });
  }
}
