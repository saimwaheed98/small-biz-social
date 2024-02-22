import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smallbiz/helper/alert_dialouge.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/helper/images_strings.dart';
import 'package:smallbiz/helper/warning_helper.dart';
import 'dart:async';

import 'package:smallbiz/models/post_model.dart';
import 'package:smallbiz/referal_link/create_link.dart';
import 'package:smallbiz/referal_link/create_link_post.dart';
import 'package:smallbiz/screens/subscription_setup/ui/subscription_setup_screen.dart';

class HomeScreenProvider extends ChangeNotifier {
  bool _isSubscribed = false;
  bool get isSubscribed => _isSubscribed;

  void isSubscribedValue(bool value) {
    _isSubscribed = value;
    notifyListeners();
  }

  // check if the user come from link
  checkUserLink(context) {
    if (!_isSubscribed) {
      // Check if subscription is not checked already
      isSubscribedValue(
          true); // Set flag to true to indicate subscription check performed
      DeepLinkService().initDynamicLinks(context);
      DeepLinkPostService().initDynamicLinks(context);
      checkSubscription().then((value) {
        if (value == true) {
          debugPrint('subscription value $value');
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return Dialouge(
                buttonText: 'Subscribe',
                details:
                    'Please Subscribe Small Biz Socail to Create Post easily',
                image: Images.sadImage,
                message: 'Oopps!',
                onPressed: () {
                  Navigator.of(context).pushNamed(SubscriptionSetup.routename);
                },
              );
            },
          );
        }
      });
    }
  }

  // check if the post is being searched
  bool _isSearching = false;
  bool get isSearching => _isSearching;

  void searching(bool value) {
    _isSearching = value;
    notifyListeners();
  }

  List<PostModel> searchList = [];
  List<PostModel> _postList = [];
  List<PostModel> get getPostList => _postList;
  void getPost(PostModel post) {
    _postList.add(post);
    notifyListeners();
  }

  void removePost(PostModel postModel) {
    _postList.removeAt(_postList.indexOf(postModel));
    notifyListeners();
  }

  Future<void> initialize() async {
    await getInfo();
    setupLifecycleListener();
  }

  Future<void> getInfo() async {
    if (Apis.auth.currentUser != null) {
      await Apis.getSelfInfo();
      notifyListeners();
    }
  }

  // check if the subscription is expired
  Future<bool> checkSubscription() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> subscriptionDetails = await Apis
          .firestore
          .collection('users')
          .doc(Apis.auth.currentUser!.uid)
          .collection('subscription')
          .doc('details')
          .get();
      if (subscriptionDetails.exists) {
        DateTime endDate =
            (subscriptionDetails.data()!['endDate'] as Timestamp).toDate();
        DateTime now = DateTime.now();

        // Check if 'endDate' is before the current date and time
        if (endDate.isBefore(now)) {
          await Apis.updateSubscriptionStatus(false);
          // Subscription is expired
          return false;
        } else {
          await Apis.updateSubscriptionStatus(true);
          // Subscription is still valid
          return true;
        }
      } else {
        await Apis.updateSubscriptionStatus(false);
        // Subscription details not found, treat as expired
        return false;
      }
    } catch (e) {
      // Handle any errors here
      debugPrint("Error checking subscription: $e");
      return false;
    }
  }

// check if the subscription is ending in 7 days
  Future<bool> checkBeforeSubscription() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> subscriptionDetails = await Apis
          .firestore
          .collection('users')
          .doc(Apis.auth.currentUser!.uid)
          .collection('subscription')
          .doc('details')
          .get();

      if (subscriptionDetails.exists) {
        DateTime endDate =
            (subscriptionDetails.data()!['endDate'] as Timestamp).toDate();
        DateTime now = DateTime.now();
        Duration remainingTime = endDate.difference(now);

        // Check if remaining time is 7 days or less
        if (remainingTime.inDays <= 7) {
          // 7 days or less remaining
          return true;
        } else {
          // More than 7 days remaining
          return false;
        }
      } else {
        // Subscription details not found, treat as expired
        return false;
      }
    } catch (e) {
      // Handle any errors here
      debugPrint("Error checking subscription: $e");
      return false;
    }
  }

  void setupLifecycleListener() {
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (Apis.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          Apis.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          Apis.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  // refresh the posts
  Future<void> refreshPostList() async {
    _postList.clear(); // Clear the existing post list
    lastDocument = null; // Reset the last document
    await get10PostsAtEach(); // Fetch new posts
    notifyListeners();
  }

  // get the posts
  DocumentSnapshot? lastDocument;

  Future<void> get10PostsAtEach() async {
    Query query = Apis.firestore.collection('posts').limit(10);

    try {
      // If we have a last document, start after it.
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      final querySnapshot = await query.get();

      // If there are no documents, we are done.
      if (querySnapshot.docs.isEmpty) {
        return;
      }

      // Remember the last document for the next query.
      lastDocument = querySnapshot.docs.last;

      for (final doc in querySnapshot.docs) {
        // _postList.add(PostModel.fromJson(doc.data() as Map<String, dynamic>));
        getPost(PostModel.fromJson(doc.data() as Map<String, dynamic>));
      }
    } catch (e) {
      WarningHelper.toastMessage('Error fetching posts: ${e.toString()}');
    }
  }
}
