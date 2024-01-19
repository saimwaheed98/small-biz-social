import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/helper/images_strings.dart';
import 'package:smallbiz/helper/text_style.dart';
import 'package:smallbiz/helper/warning_helper.dart';
import 'package:smallbiz/models/post_comment_model.dart';
import 'package:smallbiz/screens/home/post_screen_widgets/replyed_comment_container.dart';
import 'package:smallbiz/screens/home/provider/post_screen_provider.dart';
import 'package:smallbiz/screens/user_profile/ui/user_profile_screen.dart';
import 'package:smallbiz/utils/colors.dart';

class PostChatContainer extends StatelessWidget {
  final PostCommentModel data;
  final TextEditingController message;
  final FocusNode node;
  const PostChatContainer(
      {super.key,
      required this.data,
      required this.message,
      required this.node});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            PersistentNavBarNavigator.pushNewScreen(context,
                screen: UserProfile(
                  commentData: data,
                  isUser: false,
                ));
          },
          child: CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage(data.userImage),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  width: 230,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: postContainerColor,
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextStyle(
                                textName: data.userName,
                                textColor: Colors.black,
                                textSize: 10,
                                textWeight: FontWeight.w700),
                            const Icon(
                              Icons.diamond_outlined,
                              color: buttonColor,
                              size: 12,
                            ),
                          ]),
                      AppTextStyle(
                          textName: data.message,
                          textColor: primaryTextColor,
                          textSize: 10,
                          textWeight: FontWeight.w300)
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ActionText(
                        onTap: () async {
                          try {
                            if (data.commentsLikes
                                .contains(Apis.userDetail.uid)) {
                              await Apis.firestore
                                  .collection('posts')
                                  .doc(data.toId)
                                  .collection('comments')
                                  .doc(data.sent)
                                  .update({
                                'commentsLikes': FieldValue.arrayRemove(
                                    [Apis.userDetail.uid]),
                              });
                            } else {
                              await Apis.firestore
                                  .collection('posts')
                                  .doc(data.toId)
                                  .collection('comments')
                                  .doc(data.sent)
                                  .update({
                                'commentsLikes':
                                    FieldValue.arrayUnion([Apis.userDetail.uid])
                              });
                            }
                          } catch (error, context) {
                            WarningHelper.showWarningDialog(
                                context, 'Error', error.toString());
                          }
                        },
                        textName: 'Like'),
                    const SizedBox(width: 5),
                    Consumer<PostScreenProvider>(
                      builder: (context, provider, child) => ActionText(
                          onTap: () {
                            provider.setReplyComment(true);
                            FocusScope.of(context).requestFocus(node);
                          },
                          textName: 'Reply'),
                      child: ActionText(
                        onTap: () {
                          FocusScope.of(context).requestFocus(node);
                        },
                        textName: 'Reply',
                      ),
                    ),
                    const Spacer(),
                    if (data.commentsLikes.isNotEmpty)
                      Row(
                        children: [
                          AppTextStyle(
                              textName: '${data.commentsLikes.length}',
                              textColor: primaryTextColor,
                              textSize: 11,
                              textWeight: FontWeight.w700),
                          Image.asset(
                            Images.likeImage,
                            height: 25,
                            width: 25,
                          )
                        ],
                      )
                  ],
                ),
                Consumer<PostScreenProvider>(
                  builder: (context, provider, child) {
                    if (provider.replyComment == false) {
                      return StreamBuilder(
                        stream: Apis.getReplyedComments(data.fromId),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final data = snapshot.data?.docs;
                            final list = data
                                    ?.map((e) =>
                                        PostCommentModel.fromJson(e.data()))
                                    .toList() ??
                                [];
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: list.length,
                              itemBuilder: (context, index) {
                                debugPrint('lenth of list ${list.length}');
                                return CommentChatContainer(
                                  data: list[index],
                                  message: message,
                                  node: node,
                                );
                              },
                            );
                          }
                          return const SizedBox();
                        },
                      );
                    } else {
                      return CommentChatContainer(
                        data: data,
                        message: message,
                        node: node,
                      );
                    }
                  },
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  likeComment() async {
    if (data.isReply == true) {
      if (data.commentsLikes.contains(Apis.userDetail.uid)) {
        await Apis.firestore
            .collection('postsReplyedComments')
            .doc(data.toId)
            .collection('comments')
            .doc(data.sent)
            .update({
          'commentsLikes': FieldValue.arrayRemove([Apis.userDetail.uid]),
        });
      } else {
        await Apis.firestore
            .collection('postsReplyedComments')
            .doc(data.toId)
            .collection('comments')
            .doc(data.sent)
            .update({
          'commentsLikes': FieldValue.arrayUnion([Apis.userDetail.uid])
        });
      }
    } else {
      if (data.commentsLikes.contains(Apis.userDetail.uid)) {
        await Apis.firestore
            .collection('posts')
            .doc(data.toId)
            .collection('comments')
            .doc(data.sent)
            .update({
          'commentsLikes': FieldValue.arrayRemove([Apis.userDetail.uid]),
        });
      } else {
        await Apis.firestore
            .collection('posts')
            .doc(data.toId)
            .collection('comments')
            .doc(data.sent)
            .update({
          'commentsLikes': FieldValue.arrayUnion([Apis.userDetail.uid])
        });
      }
    }
  }
}

class ActionText extends StatelessWidget {
  const ActionText({super.key, required this.textName, required this.onTap});
  final String textName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
          onTap: () => onTap(),
          child: AppTextStyle(
              textName: textName,
              textColor: primaryTextColor,
              textSize: 11,
              textWeight: FontWeight.w500)),
    );
  }
}
