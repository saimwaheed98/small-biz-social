import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/helper/text_style.dart';
import 'package:smallbiz/helper/warning_helper.dart';
import 'package:smallbiz/models/post_model.dart';
import 'package:smallbiz/screens/create_account/create_account_screen_widget/bottom_container.dart';
import 'package:smallbiz/screens/home/create_post_widgets/text_field.dart';
import 'package:smallbiz/screens/home/provider/create_post_screen_provider.dart';
import 'package:smallbiz/screens/users_chat/provider/chat_screen_provider.dart';
import 'package:smallbiz/utils/colors.dart';
import 'package:smallbiz/widgets/video_player_assets.dart';

class CreatePost extends StatelessWidget {
  CreatePost({super.key});

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Provider.of<ChatScreenProvider>(context, listen: false)
        .checkUserOnlineStatus();
    var provider = Provider.of<CreatePostScreenProvider>(context);
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: white,
        title: const AppTextStyle(
            textName: 'Create a Post',
            textColor: black,
            textSize: 20,
            textWeight: FontWeight.w600),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.cancel_outlined,
              color: black,
            )),
        actions: [
          TextButton(
            onPressed: () {
              if (provider.image != null) {
                Navigator.pop(context);
                provider
                    .getPostImageUrl(scaffoldKey.currentContext)
                    .then((value) {
                  Apis.createPost(
                          titleController.text,
                          descriptionController.text,
                          PostType.image,
                          provider.url!)
                      .then((value) {
                    provider.removeImage();
                    provider.removeVideo();
                    // Navigator.pop(context);
                    WarningHelper.showWarningDialog(scaffoldKey.currentContext,
                        'Post created', 'Post created successfully');
                  });
                });
              } else if (provider.video != null) {
                Navigator.pop(context);
                provider
                    .getPostVideoUrl(scaffoldKey.currentContext)
                    .then((value) {
                  Apis.createPost(
                          titleController.text,
                          descriptionController.text,
                          PostType.video,
                          provider.videoUrl!)
                      .then((value) {
                    provider.removeImage();
                    provider.removeVideo();
                  });
                });
              } else {
                debugPrint('error while creating post');
              }
            },
            child: const AppTextStyle(
                textName: 'Post',
                textColor: Colors.blue,
                textSize: 16,
                textWeight: FontWeight.w600),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  CreatePostTextField(
                    controller: titleController,
                    hintText: 'Add a title',
                    maxLength: 70,
                    maxLines: 5,
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 230),
                    child: CreatePostTextField(
                      controller: descriptionController,
                      hintText: 'Add a description',
                      maxLength: 1200,
                      maxLines: null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Consumer<CreatePostScreenProvider>(
            builder: (context, provider, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    height: 220,
                    width: double.infinity,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        bottomSheet(scaffoldKey.currentContext);
                      },
                      child: Container(
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: provider.video != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: VideoPlayerItem(
                                      videoData: provider.video!))
                              : provider.image != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        provider.image!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                    )),
                    ),
                  ),
                  if (provider.video != null || provider.image != null)
                    Positioned(
                      right: 1,
                      top: 1,
                      child: InkWell(
                        onTap: () {
                          if (provider.image == null) {
                            provider.removeVideo();
                          } else {
                            provider.removeImage();
                          }
                        },
                        child: const Icon(
                          Icons.cancel,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  bottomSheet(context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        enableDrag: false,
        isDismissible: false,
        context: context,
        builder: (context) {
          return SizedBox(
            height: 200,
            child: Column(
              children: [
                Consumer<CreatePostScreenProvider>(
                  builder: (context, provider, child) {
                    return BottomContainer(
                      containerName: 'Upload video',
                      onPressed: () async {
                        Navigator.of(context).pop();
                        provider.pickVideo(context);
                      },
                      radiusTop: const Radius.circular(10),
                      radiusBottom: const Radius.circular(0),
                      radiusLeft: const Radius.circular(10),
                      radiusRight: const Radius.circular(0),
                    );
                  },
                ),
                Consumer<CreatePostScreenProvider>(
                  builder: (context, provider, child) {
                    return BottomContainer(
                      containerName: 'Upload image',
                      onPressed: () async {
                        Navigator.of(context).pop();
                        provider.pickImage(context);
                      },
                      radiusTop: const Radius.circular(0),
                      radiusBottom: const Radius.circular(10),
                      radiusLeft: const Radius.circular(0),
                      radiusRight: const Radius.circular(10),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: BottomContainer(
                    containerName: 'Cancel',
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    radiusTop: const Radius.circular(10),
                    radiusBottom: const Radius.circular(10),
                    radiusLeft: const Radius.circular(10),
                    radiusRight: const Radius.circular(10),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
