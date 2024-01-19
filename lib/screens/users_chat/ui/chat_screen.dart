import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/helper/image_picker.dart';
import 'package:smallbiz/models/chat_model.dart';
import 'package:smallbiz/models/post_comment_model.dart';
import 'package:smallbiz/models/post_model.dart';
import 'package:smallbiz/models/user_detail_model.dart';
import 'package:smallbiz/screens/chat_room/model/group_chat_model.dart';
import 'package:smallbiz/screens/users_chat/chat_screen_widgets/chat_screen_widgets.dart';
import 'package:smallbiz/screens/users_chat/chat_screen_widgets/voice_message_widget.dart';
import 'package:smallbiz/screens/users_chat/provider/chat_screen_provider.dart';
import 'package:smallbiz/screens/users_chat/user_chat_widgets/chat_container.dart';
import 'package:smallbiz/utils/colors.dart';
import 'package:smallbiz/widgets/video_player_assets.dart';

class ChatScreen extends StatelessWidget {
  final UserDetail? user;
  final GroupChatModel? data;
  final PostModel? postData;
  final PostCommentModel? commentUser;
  final bool? isClickAble;
  ChatScreen(
      {super.key,
      this.user,
      this.data,
      this.postData,
      this.commentUser,
      this.isClickAble});

  // controller for search
  final searchText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Provider.of<ChatScreenProvider>(context, listen: false)
        .checkUserOnlineStatus();
    var provider = Provider.of<ChatScreenProvider>(context, listen: false);
    provider.setAudioPath(File(''));
    provider.initializedRecorder();
    return WillPopScope(
      onWillPop: () {
        if (provider.isSearchingMessage) {
          provider.setSearchingMessage(false);
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: Scaffold(
        backgroundColor: scaffoldColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: ChatScreenAppBar(
            user: user,
            data: data,
            postData: postData,
            isClickAble: isClickAble,
            commentUser: commentUser,
          ),
        ),
        body: Column(children: [
          Consumer<ChatScreenProvider>(
            builder: (context, provider, child) {
              return Expanded(
                child: StreamBuilder(
                    stream: user != null
                        ? Apis.getAllMessages(user, postData, commentUser)
                        : data != null
                            ? Apis.getGroupMessages(data!)
                            : Apis.getAllMessages(user, postData, commentUser),
                    builder: (context, snapshot) {
                      final data = snapshot.data?.docs;
                      provider.messageList = data
                              ?.map((e) => MessageModel.fromJson(e.data()))
                              .toList() ??
                          [];
                      if (!snapshot.hasData) {
                        return const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator()),
                          ],
                        );
                      }
                      if (provider.messageList.isNotEmpty) {
                        return ListView.builder(
                            reverse: true,
                            itemCount: provider.isSearchingMessage
                                ? provider.searchMessageList.length
                                : provider.messageList.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return ChatContainers(
                                  messages: provider.isSearchingMessage
                                      ? provider.searchMessageList[index]
                                      : provider.messageList[index]);
                            });
                      } else if (provider.messageList.isEmpty) {
                        return Center(
                          child: Text('Say Hii! 👋',
                              style: GoogleFonts.dmSans(fontSize: 20)),
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    }),
              );
            },
          ),
          if (provider.isSearchingMessage == false)
            InputMessageField(
              user: user,
              group: data,
              postData: postData,
              commentUser: commentUser,
            )
        ]),
      ),
    );
  }
}

class InputMessageField extends StatefulWidget {
  final UserDetail? user;
  final GroupChatModel? group;
  final PostModel? postData;
  final PostCommentModel? commentUser;
  const InputMessageField(
      {super.key,
      required this.user,
      this.group,
      this.postData,
      this.commentUser});

  @override
  State<InputMessageField> createState() => _InputMessageFieldState();
}

class _InputMessageFieldState extends State<InputMessageField> {
  final messageController = TextEditingController();
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    var imagePickerProvider = Provider.of<ImagePickerProvider>(context);
    var provider = Provider.of<ChatScreenProvider>(context);
    return Column(
      children: [
        if (provider.isRecording)
          Container(
            color: white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 5,
                    color: white,
                    child: Consumer<ChatScreenProvider>(
                      builder: (context, provider, child) {
                        return LinearProgressIndicator(
                          backgroundColor: Colors.grey[200],
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.red),
                        );
                      },
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      Provider.of<ChatScreenProvider>(context, listen: false)
                          .stop(widget.user, widget.group, widget.postData,
                              widget.commentUser);
                    },
                    icon: const Icon(
                      Icons.stop,
                      color: Color(0xffE72A57),
                      size: 24,
                    )),
              ],
            ),
          ),
        if (provider.audioPath?.path.isNotEmpty ?? true)
          Consumer<ChatScreenProvider>(
            builder: (context, provider, child) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                ),
                child: Row(
                  children: [
                    VoiceMessageChat(
                      message: provider.audioPath?.path ?? '',
                      isFile: true,
                    ),
                    if (provider.isUploading == false)
                      IconButton(
                          onPressed: () {
                            provider.setAudioPath(File(''));
                          },
                          icon: const Icon(
                            Icons.clear,
                            color: Color(0xffE72A57),
                          ))
                  ],
                ),
              );
            },
          ),
        if (provider.video != null || imagePickerProvider.image != null)
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            child: Container(
              color: white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (imagePickerProvider.image != null)
                    Expanded(
                      child: Container(
                        color: white,
                        child: Consumer<ChatScreenProvider>(
                          builder: (context, provider, child) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: Image.file(
                                      imagePickerProvider.image!,
                                      fit: BoxFit.fill,
                                    )),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  if (provider.video != null)
                    Expanded(
                      child: Container(
                        color: white,
                        child: Consumer<ChatScreenProvider>(
                          builder: (context, provider, child) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: VideoPlayerItem(
                                      videoData: provider.video!)),
                            );
                          },
                        ),
                      ),
                    ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (provider.isUploading == false)
                        IconButton(
                            onPressed: () {
                              if (imagePickerProvider.image != null) {
                                imagePickerProvider.setImage(null);
                              } else {
                                provider.setVideo(null);
                              }
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Color(0xffE72A57),
                              size: 24,
                            )),
                      if (provider.isUploading)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 30,
                            width: 30,
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.red),
                            ),
                          ),
                        ),
                      if (provider.isUploading == false)
                        IconButton(
                            onPressed: () {
                              if (imagePickerProvider.image != null) {
                                provider
                                    .uploadImageToFirebase(
                                        imagePickerProvider.image!,
                                        widget.user,
                                        widget.group,
                                        widget.postData,
                                        widget.commentUser)
                                    .then((value) {
                                  Apis.sendMessage(
                                          widget.user,
                                          widget.group,
                                          widget.postData,
                                          widget.commentUser,
                                          provider.imageUrl!,
                                          Type.image)
                                      .then((value) {
                                    imagePickerProvider.setImage(null);
                                  });
                                });
                              } else {
                                provider
                                    .uploadVideoToFirebase(
                                        provider.video,
                                        widget.user,
                                        widget.group,
                                        widget.postData,
                                        widget.commentUser,
                                        context)
                                    .then((value) {
                                  Apis.sendMessage(
                                      widget.user,
                                      widget.group,
                                      widget.postData,
                                      widget.commentUser,
                                      provider.videoUrl!,
                                      Type.video);
                                  provider.setVideo(null);
                                });
                              }
                            },
                            icon: const Icon(
                              Icons.send,
                              color: Color(0xffE72A57),
                              size: 24,
                            )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        Visibility(
          visible: provider.isRecording == false &&
              imagePickerProvider.image == null &&
              provider.video == null,
          child: Container(
            color: white,
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      _showModelSheet();
                    },
                    icon: const Icon(
                      Icons.add,
                      color: Colors.grey,
                    )),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 7, bottom: 7),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 150),
                      child: SizedBox(
                          child: TextFormField(
                              focusNode: focusNode,
                              controller: messageController,
                              maxLines: null,
                              onChanged: (value) {
                                messageController.text = value;
                              },
                              style: GoogleFonts.mulish(
                                  fontSize: 14,
                                  color: const Color(0xff0F1828),
                                  fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10),
                                filled: true,
                                fillColor: const Color(0xffFF9FB0),
                                hintText: 'Message...',
                                hintStyle: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  color: primaryTextColor,
                                  fontWeight: FontWeight.w400,
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: BorderSide.none),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: BorderSide.none),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: BorderSide.none),
                              ))),
                    ),
                  ),
                ),
                if (provider.isRecording == false)
                  Consumer<ChatScreenProvider>(
                    builder: (context, provider, child) {
                      return IconButton(
                          onPressed: () {
                            if (!provider.isRecorderReady) {
                              provider.initRecoder();
                            }
                            if (provider.recoder.isRecording) {
                              provider.stop(widget.user, widget.group,
                                  widget.postData, widget.commentUser);
                            } else {
                              provider.record();
                            }
                          },
                          icon: provider.isRecording == true
                              ? const Icon(
                                  Icons.mic,
                                  color: Color(0xffE72A57),
                                )
                              : const Icon(
                                  Icons.mic,
                                  color: Color(0xffE72A57),
                                ));
                    },
                  ),
                IconButton(
                    onPressed: () {
                      if (messageController.text.isNotEmpty) {
                        Apis.sendMessage(
                            widget.user,
                            widget.group,
                            widget.postData,
                            widget.commentUser,
                            messageController.text,
                            Type.text);
                        messageController.clear();
                      } else if (provider.audioPath?.path.isNotEmpty ?? true) {
                        provider
                            .uploadAudioToFirebase(
                          provider.audioPath ?? File(''),
                          widget.user,
                          widget.group,
                          widget.postData,
                          widget.commentUser,
                        )
                            .then((value) {
                          provider.setAudioPath(File(''));
                          provider.setUploading(false);
                        });
                      }
                    },
                    icon: provider.isUploading == true
                        ? const CircularProgressIndicator()
                        : const Icon(
                            Icons.send,
                            color: Color(0xffE72A57),
                          )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _showModelSheet() {
    showModalBottomSheet(
        elevation: 10,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (context) {
          var imagePickerProvider = Provider.of<ImagePickerProvider>(context);
          var provider = Provider.of<ChatScreenProvider>(context);
          return SizedBox(
            height: 200,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text('Image'),
                  onTap: () {
                    Navigator.pop(context);
                    imagePickerProvider.getImage(context, ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.pop(context);
                    imagePickerProvider.getImage(context, ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.video_call),
                  title: const Text('Video'),
                  onTap: () {
                    Navigator.pop(context);
                    provider.getVideo(widget.user, widget.group);
                  },
                ),
              ],
            ),
          );
        });
  }
}
