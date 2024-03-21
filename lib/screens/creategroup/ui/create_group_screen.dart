import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/screens/chat_room/provider/chat_room_provider.dart';
import 'package:smallbiz/screens/creategroup/widgets/add_participents_dialogue.dart';
import 'package:smallbiz/utils/colors.dart';

import '../../../helper/firebase_helper.dart';
import '../../../helper/text_style.dart';
import '../../../widgets/app_bar.dart';
import '../../../widgets/gesture_container.dart';

class CreateGroupScreen extends StatelessWidget {
  const CreateGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ScaffoldAppBar(
        title: 'Create Group',
        onPressed: () {},
      ),
      body: Consumer<ChatRoomProvider>(builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 70,
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
              ),
              const SizedBox(
                height: 20,
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
              const SizedBox(height: 20),
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
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppTextStyle(
                    textName: 'Add Participants',
                    textColor: Colors.grey,
                    textSize: 24,
                    textWeight: FontWeight.w500,
                  ),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return dialouge(context);
                        },
                      );
                    },
                    child: Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                          color: buttonColor.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 20,
                          color: white,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: CachedNetworkImage(
                  imageUrl: Apis.userDetail.profilePicture,
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    radius: 20,
                    backgroundImage: imageProvider,
                  ),
                  errorWidget: (context, url, error) {
                    return const Icon(Icons.error);
                  },
                ),
                title: SizedBox(
                  width: 100,
                  child: AppTextStyle(
                      textName:
                          "${Apis.userDetail.firstName} ${Apis.userDetail.lastName}",
                      textColor: Colors.black,
                      textSize: 15,
                      textWeight: FontWeight.w500),
                ),
                subtitle: Text(Apis.userDetail.email),
                trailing: Container(
                  height: 20,
                  width: 80,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: buttonColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const AppTextStyle(
                      textName: 'Group admin',
                      textColor: white,
                      textSize: 10,
                      textWeight: FontWeight.w400),
                ),
              ),
              Expanded(
                child: Consumer<ChatRoomProvider>(
                    builder: (context, userProvider, child) {
                  return ListView.builder(
                    itemCount: userProvider.groupUsers.length,
                    itemBuilder: (context, index) {
                      var data = userProvider.groupUsers[index];
                      return ListTile(
                          leading: CachedNetworkImage(
                            imageUrl: data.profilePicture,
                            imageBuilder: (context, imageProvider) =>
                                CircleAvatar(
                              radius: 20,
                              backgroundImage: imageProvider,
                            ),
                            errorWidget: (context, url, error) {
                              return const Icon(Icons.error);
                            },
                          ),
                          title: SizedBox(
                            width: 100,
                            child: AppTextStyle(
                                textName: "${data.firstName} ${data.lastName}",
                                textColor: Colors.black,
                                textSize: 15,
                                textWeight: FontWeight.w500),
                          ),
                          subtitle: Text(data.email),
                          trailing: IconButton(
                            onPressed: () {
                              userProvider.setGroupUsers(data);
                            },
                            icon: const Icon(
                              Icons.close,
                              color: primaryTextColor,
                            ),
                          ));
                    },
                  );
                }),
              )
            ],
          ),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          Consumer<ChatRoomProvider>(builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureContainer(
            isLoading: provider.isLoading,
            containerName: 'Create Room',
            onTap: () async {
              if (provider.roomNameController.text.isEmpty ||
                  provider.descriptionController.text.isEmpty ||
                  provider.image == null) {
                provider.disposeControlers();
                return;
              } else if (provider.isLoading) {
                return;
              } else {
                provider.groupUsers.add(Apis.userDetail);
                await provider
                    .uploadImageToFirebase(provider.image)
                    .then((value) async {
                  await Apis.createGroup(
                          provider.roomNameController.text,
                          provider.imageUrl!,
                          provider.groupUsers.map((e) => e.uid).toList(),
                          provider.descriptionController.text)
                      .then((value) {
                    provider.setGroupUsers(Apis.userDetail);
                    provider.setImage(null);
                    provider.disposeControlers();
                    Navigator.pop(context);
                  });
                });
              }
            },
          ),
        );
      }),
    );
  }
}
