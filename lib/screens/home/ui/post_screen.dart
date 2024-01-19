import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/helper/images_strings.dart';
import 'package:smallbiz/helper/text_style.dart';
import 'package:smallbiz/models/post_comment_model.dart';
import 'package:smallbiz/models/post_model.dart';
import 'package:smallbiz/screens/home/home_screen_widgets/post_container_des.dart';
import 'package:smallbiz/screens/home/post_screen_widgets/post_screen_chat_container.dart';
import 'package:smallbiz/screens/home/provider/post_screen_provider.dart';
import 'package:smallbiz/screens/users_chat/provider/chat_screen_provider.dart';
import 'package:smallbiz/utils/colors.dart';
import 'package:smallbiz/widgets/app_bar.dart';

class PostScreen extends StatelessWidget {
  final PostModel? data;
  PostScreen({
    super.key,
    this.data,
  });

  static const routeName = '/post-screen';

  final messageController = TextEditingController();
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    Provider.of<ChatScreenProvider>(context, listen: false)
        .checkUserOnlineStatus();
    var provider = Provider.of<PostScreenProvider>(context, listen: false);
    provider.getLenth(data!.postId);
    return GestureDetector(
      onTap: () {
        provider.setReplyComment(false);
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          backgroundColor: scaffoldColor,
          appBar: const ScaffoldAppBar(title: 'Posts'),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PostContainer(data: data!, isHomeScreen: false),
                  if (data!.likes.isNotEmpty || data!.stars.isNotEmpty)
                    Row(
                      children: [
                        SizedBox(
                            height: 30,
                            width: 60,
                            child: Image.asset(
                              Images.reaction,
                              fit: BoxFit.cover,
                            )),
                        AppTextStyle(
                            textName: '${data!.likes.length}',
                            textColor: primaryTextColor,
                            textSize: 13,
                            textWeight: FontWeight.w700)
                      ],
                    ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, left: 16, right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppTextStyle(
                            textName: 'Top comments',
                            textColor: primaryTextColor,
                            textSize: 12,
                            textWeight: FontWeight.w300),
                        const SizedBox(
                          height: 10,
                        ),
                        StreamBuilder(
                            stream: Apis.getAllComments(data!.postId),
                            builder: (context, snapshot) {
                              if (snapshot.data == null) {
                                return const AppTextStyle(
                                    textName: 'Be the First one to comment',
                                    textColor: primaryTextColor,
                                    textSize: 24,
                                    textWeight: FontWeight.w300);
                              } else if (snapshot.hasData) {
                                final data = snapshot.data?.docs;
                                final list = data!
                                    .map((e) =>
                                        PostCommentModel.fromJson(e.data()))
                                    .toList();
                                return ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: list.length,
                                    itemBuilder: (context, index) {
                                      return PostChatContainer(
                                        data: list[index],
                                        message: messageController,
                                        node: focusNode,
                                      );
                                    });
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            }),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          floatingActionButton: Container(
            padding: const EdgeInsets.only(left: 30, right: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    maxLines: null,
                    focusNode: focusNode,
                    controller: messageController,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10),
                        filled: true,
                        fillColor: white,
                        hintText: 'Comment as ${data!.username}',
                        hintStyle: GoogleFonts.dmSans(
                          fontSize: 10,
                          color: primaryTextColor,
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: Consumer<PostScreenProvider>(
                          builder: (context, provider, child) {
                            return IconButton(
                                onPressed: () {
                                  if (messageController.text.isNotEmpty) {
                                    if (provider.replyComment == true) {
                                      Apis.replyedComments(
                                              data!.uid,
                                              messageController.text,
                                              Apis.userDetail.uid,
                                              Apis.userDetail.lastName,
                                              Apis.userDetail.profilePicture)
                                          .then((value) {
                                        Apis.getCommentLength(data!.postId);
                                      });
                                      messageController.text = '';
                                      provider.setReplyComment(false);
                                    } else {
                                      Apis.sendPostMessage(
                                              data!.postId,
                                              messageController.text,
                                              Apis.userDetail.uid,
                                              Apis.userDetail.firstName +
                                                  Apis.userDetail.lastName,
                                              Apis.userDetail.profilePicture)
                                          .then((value) {
                                        Apis.getCommentLength(data!.postId);
                                      });
                                      messageController.text = '';
                                    }
                                    FocusScope.of(context).unfocus();
                                  }
                                },
                                icon: const Icon(
                                  Icons.send,
                                  color: buttonColor,
                                ));
                          },
                        )),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
