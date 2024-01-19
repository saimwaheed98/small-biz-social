import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/helper/shimmer_effect.dart';
import 'package:smallbiz/helper/text_style.dart';
import 'package:smallbiz/helper/warning_helper.dart';
import 'package:smallbiz/models/chat_model.dart';
import 'package:smallbiz/screens/users_chat/chat_screen_widgets/voice_message_widget.dart';
import 'package:smallbiz/screens/users_chat/provider/chat_screen_provider.dart';
import 'package:smallbiz/utils/colors.dart';
import 'package:smallbiz/utils/date_time.dart';
import 'package:smallbiz/widgets/video_player_internet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voice_message_package/voice_message_package.dart';

class ChatContainers extends StatelessWidget {
  final MessageModel messages;
  const ChatContainers({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    bool isMe = Apis.user.uid == messages.fromId;
    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe, context);
      },
      child: isMe
          ? _chatContainerIsMe(false, context)
          : _chatContainerOthers(false, context),
    );
  }

  Widget _chatContainerIsMe(bool isForward, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: Color(0xffFF9FB0),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // if the user want to reply a message of the partcular message then show that container
                  if (isForward == true)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.only(
                            top: 10, left: 16, right: 16, bottom: 16),
                        height: 60,
                        decoration: const BoxDecoration(
                            color: Color(0xffEDEDED),
                            border: Border(
                                right:
                                    BorderSide(color: buttonColor, width: 3))),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AppTextStyle(
                                textName: 'You',
                                textColor: Colors.blue,
                                textSize: 10,
                                textWeight: FontWeight.w600),
                            AppTextStyle(
                                textName: 'Can i come Over?',
                                textColor: primaryTextColor,
                                textSize: 14,
                                textWeight: FontWeight.w400)
                          ],
                        ),
                      ),
                    ),
                  // if the message is i the type of image only show that thing
                  if (messages.type == Type.image)
                    InkWell(
                      onTap: () {
                        PersistentNavBarNavigator.pushNewScreen(context,
                            screen: ImageOpenar(imageUrl: messages.message),
                            withNavBar: false);
                      },
                      child: SizedBox(
                        height: 150,
                        width: 250,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                              imageUrl: messages.message,
                              progressIndicatorBuilder: (context, url,
                                      downloadProgress) =>
                                  const ImageLoading(height: 150, width: 250),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.image)),
                        ),
                      ),
                    ),
                  // if the message is in the form of voice only show that container
                  if (messages.type == Type.voice)
                    VoiceMessageChat(message: messages.message, isFile: false),
                  // if the message is in the form of text so only show the text
                  if (messages.type == Type.text)
                    InkWell(
                      onTap: () {
                        Uri url = Uri.parse(messages.message);
                        launchUrl(url, mode: LaunchMode.externalApplication);
                      },
                      child: messages.message.contains('http')
                          ? Consumer<ChatScreenProvider>(
                              builder: (context, provider, child) {
                              return LinkPreview(
                                  openOnPreviewImageTap: true,
                                  openOnPreviewTitleTap: true,
                                  onPreviewDataFetched: (dataFromUrl) {
                                    provider.setData(dataFromUrl);
                                  },
                                  previewData: provider.data,
                                  text: messages.message,
                                  width: MediaQuery.of(context).size.width);
                            })
                          : AppTextStyle(
                              textName: messages.message,
                              textColor: primaryTextColor,
                              textSize: 14,
                              textWeight: FontWeight.w400),
                    ),
                  // Inside your _chatContainerIsMe method
                  if (messages.type == Type.video)
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: VideoPlayerItem(data: messages)),
                  // set the read status and the unread status
                  SizedBox(
                    height: 10,
                    width: 70,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppTextStyle(
                            textName: MyDateUtil.getFormattedTime(
                                context: context, time: messages.sent),
                            textColor: primaryTextColor,
                            textSize: 10,
                            textWeight: FontWeight.w400),
                        if (messages.read.isNotEmpty)
                          const AppTextStyle(
                              textName: ' .Read',
                              textColor: primaryTextColor,
                              textSize: 10,
                              textWeight: FontWeight.w400),
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ],
    );
  }

  Widget _chatContainerOthers(bool isForward, BuildContext context) {
    if (messages.read.isEmpty) {
      Apis.updateMessageReadStatus(messages);
      debugPrint('read status updated');
    }
    if (messages.read.isEmpty) {
      Apis.updateGroupMessageReadStatus(messages);
      debugPrint('read status updated');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    topRight: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // if the user want to reply a message of the partcular message then show that container
                  if (isForward == true)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.only(
                            top: 10, left: 16, right: 16, bottom: 16),
                        height: 60,
                        decoration: const BoxDecoration(
                            color: Color(0xffEDEDED),
                            border: Border(
                                left:
                                    BorderSide(color: buttonColor, width: 3))),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextStyle(
                                textName: 'You',
                                textColor: Colors.blue,
                                textSize: 10,
                                textWeight: FontWeight.w600),
                            AppTextStyle(
                                textName: 'Can i come Over?',
                                textColor: primaryTextColor,
                                textSize: 14,
                                textWeight: FontWeight.w400)
                          ],
                        ),
                      ),
                    ),
                  // if the message is in the type of image only show that thing
                  if (messages.type == Type.image)
                    InkWell(
                      onTap: () {
                        ImageOpenar(imageUrl: messages.message);
                      },
                      child: SizedBox(
                        height: 150,
                        width: 250,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                              imageUrl: messages.message,
                              progressIndicatorBuilder: (context, url,
                                      downloadProgress) =>
                                  const ImageLoading(height: 150, width: 250),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.image)),
                        ),
                      ),
                    ),
                  // if the message is in the form of voice only show that container
                  if (messages.type == Type.voice)
                    VoiceMessageView(
                      activeSliderColor: buttonColor,
                      circlesColor: buttonColor,
                      backgroundColor: const Color(0xffEDEDED),
                      controller: VoiceController(
                        audioSrc: messages.message,
                        maxDuration: const Duration(seconds: 120),
                        isFile: false,
                        onComplete: () {
                          debugPrint('onComplete');
                        },
                        onPause: () {
                          debugPrint('onPause');
                        },
                        onPlaying: () {
                          debugPrint('onPlaying');
                        },
                      ),
                      innerPadding: 12,
                      cornerRadius: 20,
                    ),
                  // if the message is in the form of text so only show the text
                  if (messages.type == Type.text)
                    InkWell(
                      onTap: () {
                        Uri url = Uri.parse(messages.message);
                        launchUrl(url, mode: LaunchMode.externalApplication);
                      },
                      child: messages.message.contains('http')
                          ? Consumer<ChatScreenProvider>(
                              builder: (context, provider, child) {
                              return LinkPreview(
                                  openOnPreviewImageTap: true,
                                  openOnPreviewTitleTap: true,
                                  onPreviewDataFetched: (dataFromUrl) {
                                    provider.setData(dataFromUrl);
                                  },
                                  previewData: provider.data,
                                  text: messages.message,
                                  width: MediaQuery.of(context).size.width);
                            })
                          : AppTextStyle(
                              textName: messages.message,
                              textColor: primaryTextColor,
                              textSize: 14,
                              textWeight: FontWeight.w400),
                    ),

                  // if the message is in the type of video only show that thing
                  if (messages.type == Type.video)
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: VideoPlayerItem(data: messages)),
                  // get the formated time and show if the message is readed
                  SizedBox(
                    height: 10,
                    width: 70,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppTextStyle(
                            textName: MyDateUtil.getFormattedTime(
                                context: context, time: messages.sent),
                            textColor: primaryTextColor,
                            textSize: 10,
                            textWeight: FontWeight.w400),
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ],
    );
  }

  void _showBottomSheet(bool isMe, context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * .015,
                    horizontal: MediaQuery.of(context).size.width * .4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey),
              ),
              messages.type == Type.text
                  ?
                  // copy option
                  _OptionItem(
                      icon: const Icon(Icons.copy_all_outlined,
                          color: Colors.blue, size: 26),
                      name: 'Copy Text',
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: messages.message))
                            .then((value) {
                          Navigator.pop(context);
                          WarningHelper.toastMessage('Text Copied!');
                        });
                      },
                    )
                  : messages.type == Type.image
                      ?
                      // save option
                      _OptionItem(
                          icon: const Icon(Icons.download_rounded,
                              color: Colors.blue, size: 26),
                          name: 'Save Image',
                          onTap: () async {
                            try {
                              await GallerySaver.saveImage(messages.message,
                                      albumName: 'Small Biz Social Images')
                                  .then((success) {
                                //for hiding bottom sheet
                                Navigator.pop(context);
                                if (success != null && success) {
                                  WarningHelper.toastMessage('Image Saved');
                                }
                              });
                            } catch (e) {
                              WarningHelper.toastMessage(
                                  'Failed to save image');
                              debugPrint(e.toString());
                            }
                          },
                        )
                      : messages.type == Type.voice
                          ? const SizedBox.shrink()
                          : _OptionItem(
                              icon: const Icon(Icons.download_rounded,
                                  color: Colors.blue, size: 26),
                              name: 'Save Video',
                              onTap: () async {
                                try {
                                  await GallerySaver.saveVideo(messages.message,
                                          albumName: 'Small Biz Social Videos')
                                      .then((success) {
                                    //for hiding bottom sheet
                                    Navigator.pop(context);
                                    if (success != null && success) {
                                      WarningHelper.toastMessage('Video Saved');
                                    }
                                  });
                                } catch (e) {
                                  WarningHelper.toastMessage(
                                      'Failed to save Video');
                                  debugPrint(e.toString());
                                }
                              },
                            ),
              if (isMe)
                const Divider(
                  color: Colors.black54,
                  endIndent: 10,
                  indent: 10,
                ),
              if (messages.type == Type.text && isMe)
                // edit option
                _OptionItem(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 26),
                  name: 'Edit Message',
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) {
                        return MessageUpdateDialouge(message: messages);
                      },
                    );
                  },
                ),
              if (isMe)
                // delete option
                _OptionItem(
                  icon: const Icon(Icons.delete_forever,
                      color: Colors.red, size: 26),
                  name: 'Delete Message',
                  onTap: () {
                    Navigator.pop(context);
                    Apis.deleteMessage(messages).then((value) {});
                  },
                ),
              const Divider(
                color: Colors.black54,
                endIndent: 10,
                indent: 10,
              ),
              // sent time
              _OptionItem(
                icon: const Icon(Icons.remove_red_eye,
                    color: Colors.blue, size: 26),
                name:
                    'Sent At : ${MyDateUtil.getMessageTime(context: context, time: messages.sent)}',
                onTap: () {},
              ),
              // read time
              _OptionItem(
                icon: const Icon(Icons.remove_red_eye,
                    color: Colors.green, size: 26),
                name: messages.read.isEmpty
                    ? 'Read At : Not seen yet'
                    : 'Read At : ${MyDateUtil.getMessageTime(context: context, time: messages.read)}',
                onTap: () {},
              ),
            ],
          );
        });
  }
}

class ImageOpenar extends StatelessWidget {
  final String imageUrl;
  const ImageOpenar({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.image),
        ),
      ),
    );
  }
}

class MessageUpdateDialouge extends StatelessWidget {
  final MessageModel message;
  const MessageUpdateDialouge({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    String updatedMsg = message.message;
    return AlertDialog(
      contentPadding:
          const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      //title
      title: const Row(
        children: [
          Icon(
            Icons.message,
            color: Colors.blue,
            size: 28,
          ),
          Text(' Update Message')
        ],
      ),
      //content
      content: TextFormField(
        initialValue: updatedMsg,
        autofocus: true,
        maxLines: null,
        onChanged: (value) => updatedMsg = value,
        decoration: InputDecoration(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
      ),

      //actions
      actions: [
        //cancel button
        MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.actor(fontSize: 16, color: Colors.blue),
            )),

        //update button
        MaterialButton(
            onPressed: () {
              Navigator.pop(context);
              Apis.updateMessage(message, updatedMsg);
            },
            child: Text(
              'Update',
              style: GoogleFonts.actor(color: Colors.blue, fontSize: 16),
            ))
      ],
    );
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            icon,
            Text(
              '         $name',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
