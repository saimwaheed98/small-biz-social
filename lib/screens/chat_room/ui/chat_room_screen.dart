import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/helper/text_style.dart';
import 'package:smallbiz/screens/chat_room/chat_room_widgets/user_chat_container.dart';
import 'package:smallbiz/screens/chat_room/chat_room_widgets/users_room_des.dart';
import 'package:smallbiz/screens/chat_room/model/group_chat_model.dart';
import 'package:smallbiz/screens/chat_room/provider/chat_room_provider.dart';
import 'package:smallbiz/screens/users_chat/ui/chat_screen.dart';
import 'package:smallbiz/utils/colors.dart';
import 'package:smallbiz/widgets/app_bar.dart';
import 'package:smallbiz/widgets/gesture_container.dart';

class ChatRoomScreen extends StatelessWidget {
  const ChatRoomScreen({super.key});
  static const routename = '/Chat_Rooms';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: scaffoldColor,
      appBar: ScaffoldAppBar(
        title: 'Chat Rooms',
        onPressed: () {},
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 5,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              height: 100,
              width: MediaQuery.of(context).size.height,
              color: const Color(0xffFFBEC1),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15, left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: white),
                          child: IconButton(
                              onPressed: () {
                                showDialog(
                                    useSafeArea: true,
                                    context: context,
                                    builder: (context) => dialouge(context));
                              },
                              icon: const Icon(
                                Icons.add,
                                color: Colors.grey,
                              )),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Create New \n Chat Room',
                          style: GoogleFonts.dmSans(
                              fontSize: 10, fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                  ),
                  StreamBuilder(
                    stream: Apis.getMyCreatedGroup(),
                    builder: (context, snapshot) {
                      if (snapshot.data?.docs.isEmpty ?? true) {
                        return const SizedBox.shrink();
                      } else if (snapshot.data!.docs.isNotEmpty) {
                        var data = snapshot.data?.docs;
                        var list = data
                                ?.map((e) => GroupChatModel.fromJson(e.data()))
                                .toList() ??
                            [];
                        return ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            var groupData = list[index];
                            return InkWell(
                              onTap: () {
                                PersistentNavBarNavigator.pushNewScreen(context,
                                    withNavBar: false,
                                    screen: ChatScreen(
                                      data: groupData,
                                    ));
                              },
                              child: UserRoomContainer(
                                groupData: groupData,
                              ),
                            );
                          },
                        );
                      } else {
                        return const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: buttonColor,
                              backgroundColor: Colors.white,
                              strokeWidth: 1),
                        );
                      }
                    },
                  )
                ],
              ),
            ),
          ),
          StreamBuilder(
              stream: Apis.getAllGroup(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Something went wrong'),
                  );
                } else if (!snapshot.hasData) {
                  return const Center(
                    child: Text('No Chat Room'),
                  );
                } else if (snapshot.hasData) {
                  var data = snapshot.data?.docs;
                  var list = data
                          ?.map((e) => GroupChatModel.fromJson(e.data()))
                          .toList() ??
                      [];
                  return Expanded(
                    child: ListView.builder(
                      itemCount: list.length,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return UserChatContainer(
                          data: list[index],
                          isClickAble: false,
                        );
                      },
                    ),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              })
        ],
      ),
    );
  }

  dialouge(context) {
    return Consumer<ChatRoomProvider>(
      builder: (context, provider, child) {
        return AlertDialog(
          elevation: 10,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: const AppTextStyle(
              textName: 'Create New Room',
              textColor: primaryTextColor,
              textSize: 20,
              textWeight: FontWeight.w600),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: provider.image == null
                      ? null
                      : FileImage(provider.image!),
                  child: IconButton(
                      onPressed: () {
                        provider.getImage(context, ImageSource.gallery);
                      },
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.grey,
                      )),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 45,
                  child: TextField(
                    controller: provider.roomNameController,
                    decoration: InputDecoration(
                      fillColor: Colors.grey[200],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      labelText: 'Enter Chat Room Name',
                      labelStyle: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 45,
                  child: TextField(
                    controller: provider.descriptionController,
                    decoration: InputDecoration(
                      fillColor: Colors.grey[200],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      labelText: 'Enter Description',
                      labelStyle: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureContainer(
                  containerName: 'Create Room',
                  onTap: () {
                    if (provider.roomNameController.text.isEmpty ||
                        provider.descriptionController.text.isEmpty ||
                        provider.image == null) {
                      provider.disposeControlers();
                      return;
                    }
                    provider
                        .uploadImageToFirebase(provider.image)
                        .then((value) {
                      Apis.createGroup(
                              provider.roomNameController.text,
                              provider.imageUrl!,
                              [Apis.userDetail.uid],
                              provider.descriptionController.text)
                          .then((value) {
                        provider.setImage(null);
                        provider.disposeControlers();
                        Navigator.pop(context);
                      });
                    });
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
