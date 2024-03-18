import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:smallbiz/helper/warning_helper.dart';
import 'package:smallbiz/models/chat_model.dart';
import 'package:smallbiz/models/notification_model.dart';
import 'package:smallbiz/models/subscription_model.dart';
import 'package:smallbiz/screens/chat_room/model/group_chat_model.dart';
import 'package:smallbiz/models/post_comment_model.dart';
import 'package:smallbiz/models/post_model.dart';
import 'package:smallbiz/models/user_detail_model.dart';
import 'package:uuid/uuid.dart';

class Apis {
  // firebase auth variables
  static FirebaseAuth auth = FirebaseAuth.instance;
// firebase firestore variable
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
// firebase storage variable
  static FirebaseStorage storage = FirebaseStorage.instance;
// for getting the pushToken
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  // for accessing the current user
  static User get user => auth.currentUser!;

  // save the data in the variable
  static UserDetail userDetail = UserDetail(
      firstName: user.displayName ?? '',
      profilePicture: user.photoURL ?? '',
      uid: user.uid,
      lastName: '',
      createdAt: '',
      subscription: false,
      pushToken: '',
      email: user.email!,
      isOnline: false,
      lastActive: '',
      bio: 'Hey there! I am using SmallBizSocial');

  // for creating a new user
  static Future<void> createUser(
      {String? firstname = '', String? lastname = ''}) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = UserDetail(
      uid: user.uid,
      firstName: firstname!,
      lastName: lastname!,
      email: user.email.toString(),
      bio: "Hey there! I am using SmallBizSocial",
      profilePicture: user.photoURL.toString(),
      createdAt: time,
      lastActive: time,
      subscription: false,
      pushToken: '',
      isOnline: false,
    );

    await firestore.collection('users').doc(user.uid).set(chatUser.toJson());
    // Update the 'userDetail' variable after saving in Firestore
    userDetail = UserDetail(
      uid: user.uid,
      firstName: firstname,
      email: user.email.toString(),
      bio: "Hey, I'm using SmallBizSocial",
      profilePicture: user.photoURL.toString(),
      createdAt: time,
      lastActive: time,
      subscription: false,
      lastName: lastname,
      pushToken: '',
      isOnline: false,
    );
  }

  // upgarde the user subscription
  static Future<void> setSubscription(
    int subscriptionPrice,
  ) async {
    SubscriptionModel subscription = SubscriptionModel(
        id: user.uid,
        price: subscriptionPrice.toDouble(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        startDate: DateTime.now());
    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('subscription')
        .doc('details')
        .set(subscription.toMap());
  }

  // update the user subscription status
  static Future<void> updateSubscriptionStatus(bool status) async {
    await firestore.collection('users').doc(user.uid).update({
      'subscription': status,
    }).then((value) {
      userDetail.subscription = status;
    });
  }

  // get the data of the user subscription
  static Future<Map<String, dynamic>> getSubscriptionDetails() async {
    Map<String, dynamic> subscriptiondata = {};
    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('subscription')
        .doc('details')
        .get()
        .then((value) {
      subscriptiondata = value.data()!;
    });
    return subscriptiondata;
  }

  // update user bio
  static Future<void> updateBio(String bio) async {
    await firestore.collection('users').doc(userDetail.uid).update({
      'bio': bio,
    }).then((value) {
      userDetail.bio = bio;
    });
  }

  // for getting and updating the pushToken in firestore
  static Future<void> getFirebaseMessagingToken() async {
    await messaging.requestPermission();
    await messaging.getToken().then((pushToken) {
      if (pushToken != null) {
        debugPrint('Push Token: $pushToken');
        userDetail.pushToken = pushToken;
      }
    });
  }

  // sending the push notification
  static Future<void> sendPushNotification(
      UserDetail chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": userDetail.firstName + userDetail.lastName,
          "body": msg,
          "android_channel_id": "chats"
        },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAzyI-suw:APA91bEayOg2pAF-ftFK7QbXB90ET0lIhxHPhi27E2FNWucDGVOJ8wWb--fO21idwLdCeaGcYUGv-0Yy_qM5d5H4xOMBgcXLX8Uj9diTETq7Yf0yuJAtzzv2eVo-TR-iZyhKMWWYYY1q'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  // getting self info from firestore
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((value) async {
      userDetail = UserDetail.fromJson(value.data()!);
      await getFirebaseMessagingToken();
    });
  }

  // get the selfInfo While Login again
  static Future<void> getLoginInfo(String user) async {
    await firestore.collection('users').doc(user).get().then((value) {
      userDetail = UserDetail.fromJson(value.data()!);
    });
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'isOnline': isOnline,
      'lastActive': DateTime.now().millisecondsSinceEpoch.toString(),
      'pushToken': userDetail.pushToken,
    });
  }

  // get users for chat
  // for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .where('uid', isNotEqualTo: user.uid)
        .snapshots();
  }

  ///************** Chat Screen Related APIs **************

  // chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)

  // useful for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      UserDetail? user, PostModel? postUser, PostCommentModel? commentUser) {
    return firestore
        .collection(
            'chats/${getConversationID(user?.uid ?? postUser?.uid ?? commentUser!.fromId)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(
      UserDetail? chatUser,
      GroupChatModel? group,
      PostModel? postData,
      PostCommentModel? commentUser,
      String msg,
      Type type) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final MessageModel message = MessageModel(
        toId: chatUser?.uid ??
            group?.groupId ??
            postData?.uid ??
            commentUser!.fromId,
        message: msg,
        read: '',
        type: type,
        fromId: user.uid,
        receiverName: chatUser?.firstName ??
            group?.groupAdminName ??
            postData?.username ??
            commentUser!.userName,
        senderName: userDetail.firstName + userDetail.lastName,
        sent: time);

    if (chatUser != null) {
      final ref = firestore
          .collection('chats/${getConversationID(chatUser.uid)}/messages/');
      await ref.doc(time).set(message.toJson()).then((value) {
        sendPushNotification(
            chatUser,
            type == Type.text
                ? msg
                : type == Type.video
                    ? '🎞️ Video'
                    : type == Type.image
                        ? '🖼️ Image'
                        : '📻 Audio');
        sendNotification(chatUser, msg, false);
      });
    } else if (group != null) {
      final ref = firestore.collection('chats/${group.groupId}/messages/');
      await ref.doc(time).set(message.toJson());
    } else {
      final ref = firestore.collection(
          'chats/${getConversationID(postData?.uid ?? commentUser!.fromId)}/messages/');
      await ref.doc(time).set(message.toJson());
    }
  }

  // for getting the notification in notification screen
  static Future<void> sendNotification(
      UserDetail chatUser, String msg, bool isFriend) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    //message to send
    final NotificationModel notification = NotificationModel(
        senderId: user.uid,
        receiverId: chatUser.uid,
        message: msg,
        title: Apis.userDetail.firstName + Apis.userDetail.lastName,
        senderImage: Apis.userDetail.profilePicture,
        sentAt: time,
        isFriend: isFriend);

    final ref = firestore.collection('notifications');
    await ref.doc(time).set(notification.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getNotification() {
    return firestore
        .collection('notifications')
        .where('receiverId', isEqualTo: user.uid)
        .snapshots();
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(MessageModel message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      UserDetail user) {
    return firestore
        .collection('chats/${getConversationID(user.uid)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // //send chat image
  // static Future<String> sendChatImage(
  //     UserDetail? chatUser, GroupChatModel? group, File file) async {
  //   //getting image file extension
  //   final ext = file.path.split('.').last;

  //   //storage file ref with path
  //   final ref = storage.ref().child(
  //       'images/${getConversationID(chatUser!.uid)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

  //   //uploading image
  //   await ref
  //       .putFile(file, SettableMetadata(contentType: 'image/$ext'))
  //       .then((loadingValue) {
  //     log('Data Transferred: ${loadingValue.bytesTransferred / 1000} kb');
  //   });

  //   //updating image in firestore database
  //   final imageUrl = await ref.getDownloadURL();
  //   return imageUrl;
  //   // await sendMessage(chatUser, group, ,imageUrl, Type.image);
  // }

  //delete message
  static Future<void> deleteMessage(MessageModel message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.message).delete();
    }
  }

  // delete the chat room from firestore
  static Future<void> deleteChat(
      {GroupChatModel? group, UserDetail? user}) async {
    String conversationID =
        getConversationID(group != null ? group.groupId : user!.uid);

    try {
      // Get a reference to the chat room
      DocumentReference chatRef =
          firestore.collection('chats').doc(conversationID);

      // Get all messages in the chat room
      QuerySnapshot<Map<String, dynamic>> messagesSnapshot =
          await chatRef.collection('messages').get();

      // Delete each message in the chat room
      for (var messageDoc in messagesSnapshot.docs) {
        await messageDoc.reference.delete();
      }

      // Delete the chat room document itself
      await chatRef.delete();
    } catch (e) {
      debugPrint('error ${e.toString()}');
      WarningHelper.toastMessage(e.toString());
    }
  }

  //update message
  static Future<void> updateMessage(
      MessageModel message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'message': updatedMsg});
  }

  /* ************** Posts Realated Work ************** */

  // for creating Post
  static Future<void> createPost(
    String title,
    String description,
    PostType postType,
    String postData,
  ) async {
    final time = DateTime.now().millisecondsSinceEpoch;
    const postId = Uuid();
    final id = postId.v4();
    final post = PostModel(
        uid: user.uid,
        postTitle: title,
        postType: postType,
        publishDate: time,
        description: description,
        profileImage: userDetail.profilePicture,
        postId: id,
        postData: postData,
        likes: [],
        stars: [],
        comments: [],
        username: '${userDetail.firstName} ${userDetail.lastName}');

    final ref = firestore.collection('posts');
    await ref.doc(id).set(post.toJson());
  }

  // for sending the message in post
  static Future<void> sendPostMessage(String postId, String msg, String userId,
      String userName, String userImage) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final PostCommentModel message = PostCommentModel(
        toId: postId,
        message: msg,
        fromId: userId,
        sent: time,
        userName: userName,
        commentsLikes: [],
        isReply: false,
        userImage: userImage);
    final ref = firestore.collection('posts/$postId/comments/');
    await ref.doc(time).set(message.toJson());
  }

  // for getting all comments of a specific post from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllComments(
      String postId) {
    return firestore
        .collection('posts/$postId/comments/')
        .orderBy('sent', descending: false)
        .snapshots();
  }

  // for getting all posts from firestore
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllPosts() {
    return firestore
        .collection('posts')
        .orderBy('likes', descending: true)
        .snapshots();
  }

  // delete the post
  static Future<void> deletePost(PostModel post) async {
    await firestore.collection('posts').doc(post.postId).delete();
  }

  // for getting currentUser posts from firestore
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyPosts(
      {UserDetail? user, PostModel? postUser, PostCommentModel? commentUser}) {
    return firestore
        .collection('posts')
        .where('uid',
            isEqualTo:
                user != null ? user.uid : postUser?.uid ?? commentUser!.fromId)
        .snapshots();
  }

  // update the length of the comment in the post model
  static Future<void> getCommentLength(String postId) async {
    await FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'comments': FieldValue.arrayUnion([Apis.userDetail.uid])
    });
    // This will give you the number of comments
  }

  // get the replyed comments
  static Future<void> replyedComments(String commentId, String msg,
      String userId, String userName, String userImage) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final PostCommentModel message = PostCommentModel(
        toId: commentId,
        message: msg,
        fromId: userId,
        sent: time,
        userName: userName,
        commentsLikes: [],
        isReply: false,
        userImage: userImage);
    final ref = firestore.collection('postsReplyedComments');
    await ref
        .doc(commentId)
        .collection('comments')
        .doc(time)
        .set(message.toJson());
  }

  // get the replyed comments
  static Stream<QuerySnapshot<Map<String, dynamic>>> getReplyedComments(
      String commentId) {
    return firestore
        .collection('postsReplyedComments')
        .doc(commentId)
        .collection('comments')
        .snapshots();
  }

  // like the post
  static Future<void> likePost(String postId, List likes, context) async {
    try {
      if (likes.contains(userDetail.uid)) {
        await firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([userDetail.uid]),
        });
      } else {
        await firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([userDetail.uid])
        });
      }
    } catch (error) {
      WarningHelper.showWarningDialog(context, 'Error', error.toString());
    }
  }

  // gave star the post
  static Future<void> starPost(String postId, List likes, context) async {
    try {
      if (likes.contains(userDetail.uid)) {
        await firestore.collection('posts').doc(postId).update({
          'stars': FieldValue.arrayRemove([userDetail.uid]),
        });
      } else {
        await firestore.collection('posts').doc(postId).update({
          'stars': FieldValue.arrayUnion([userDetail.uid])
        });
      }
    } catch (error) {
      WarningHelper.showWarningDialog(context, 'Error', error.toString());
    }
  }

  // get the lenght of the comments for the post
  static Future<int> getCommentsLength(String postId) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .get();
    return querySnapshot.size; // This will give you the number of comments
  }

  /// ************** groupChatRelatedWork ****************

  // for creating a new group
  static Future<void> createGroup(String groupName, String groupImage,
      List members, String groupDescription) async {
    final time = DateTime.now().millisecondsSinceEpoch;
    const groupId = Uuid();
    final id = groupId.v4();
    final group = GroupChatModel(
      groupMembers: members,
      roomImage: groupImage,
      publishDate: time,
      groupName: groupName,
      groupId: id,
      groupDescription: groupDescription,
      groupAdmin: user.uid,
      groupAdminName: userDetail.firstName,
      groupAdminImage: userDetail.profilePicture,
    );

    final ref = firestore.collection('groups');
    await ref.doc(id).set(group.toJson());
  }

  // for getting all the groups from firestore
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllGroup() {
    return firestore
        .collection('groups')
        // .where('groupMembers', arrayContains: userDetail.uid)
        .snapshots();
  }

  // for getting the groups where the current user is admin
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyCreatedGroup() {
    return firestore
        .collection('groups')
        .where('groupAdmin', isEqualTo: userDetail.uid)
        .snapshots();
  }

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getGroupMessages(
      GroupChatModel group) {
    return firestore
        .collection('chats/${group.groupId}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // get the last group message
  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastGroupMessage(
      GroupChatModel group) {
    return firestore
        .collection('chats/${group.groupId}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  //update read status of message
  static Future<void> updateGroupMessageReadStatus(MessageModel message) async {
    firestore
        .collection('chats/${message.toId}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // get the members for the group
  static Future<void> getMembers(String postId, List members, context) async {
    try {
      if (members.contains(userDetail.uid)) {
        await firestore.collection('groups').doc(postId).update({
          'groupMembers': FieldValue.arrayRemove([userDetail.uid]),
        });
      } else {
        await firestore.collection('groups').doc(postId).update({
          'groupMembers': FieldValue.arrayUnion([userDetail.uid])
        });
      }
    } catch (error) {
      WarningHelper.showWarningDialog(context, 'Error', error.toString());
    }
  }

  /// ***************** search the post **********
  Stream<QuerySnapshot<Map<String, dynamic>>> searchPosts(String searchValue) {
    return firestore
        .collection('posts')
        .where('postTitle', isGreaterThanOrEqualTo: searchValue)
        .snapshots();
  }
}
