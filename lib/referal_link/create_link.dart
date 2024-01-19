import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/models/user_detail_model.dart';
import 'package:smallbiz/screens/user_profile/ui/user_profile_screen.dart';

class DeepLinkService with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<String> createReferLink(String profileCode) async {
    FirebaseDynamicLinks links = FirebaseDynamicLinks.instance;
    try {
      setLoading(true);
      final DynamicLinkParameters dynamicLinkParameters = DynamicLinkParameters(
        uriPrefix: 'https://smallbizsocial.page.link',
        link:
            Uri.parse('https://smallbizsocial.page.link?profile=$profileCode'),
        androidParameters: const AndroidParameters(
          packageName: 'com.smartbiz.smartbiz',
          minimumVersion: 1,
        ),
        iosParameters: const IOSParameters(
          bundleId: 'com.smartbiz.smartbiz',
          minimumVersion: '1',
        ),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: 'Small Biz Social',
          description:
              'Small Biz Social is a social media app for small business',
          imageUrl: Uri.parse(
              'https://firebasestorage.googleapis.com/v0/b/small-biz-social-30ff3.appspot.com/o/playstore.png?alt=media&token=0b61b022-ae09-458b-a616-8751924fce07'),
        ),
      );

      final shortLink = await links.buildShortLink(dynamicLinkParameters);
      return shortLink.shortUrl.toString();
    } catch (e) {
      setLoading(false);
      debugPrint('Error: $e');
      return '';
    }
  }

  void initDynamicLinks(BuildContext context) async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      final Uri? deepLink = dynamicLinkData.link;
      if (deepLink != null) {
        final queryParams = deepLink.queryParameters;
        final profileCode = queryParams['profile'];
        if (profileCode != null) {
          Apis.firestore
              .collection('users')
              .doc(profileCode)
              .get()
              .then((snapshot) {
            if (snapshot.exists) {
              final userDetail = UserDetail.fromJson(snapshot.data()!);
              PersistentNavBarNavigator.pushNewScreen(context,
                  screen: UserProfile(
                    user: userDetail,
                    isUser: false,
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
