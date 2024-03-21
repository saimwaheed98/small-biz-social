import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/helper/text_style.dart';
import 'package:smallbiz/utils/colors.dart';
import 'package:smallbiz/widgets/gesture_container.dart';

import '../../chat_room/provider/chat_room_provider.dart';
import '../../users_chat/provider/chat_screen_provider.dart';

dialouge(context) {
  var chatProvider = Provider.of<ChatScreenProvider>(context, listen: false);
  return Consumer<ChatRoomProvider>(
    builder: (context, provider, child) {
      return AlertDialog(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: const AppTextStyle(
            textName: 'Search Participents',
            textColor: primaryTextColor,
            textSize: 20,
            textWeight: FontWeight.w600),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 45,
                child: TextField(
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      chatProvider.setSearching(true);
                      chatProvider.searchList.clear();
                      for (var i in chatProvider.userList) {
                        if (i.firstName
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            i.lastName
                                .toLowerCase()
                                .contains(value.toLowerCase())) {
                          chatProvider.searchList.add(i);
                        }
                      }
                    } else {
                      chatProvider.setSearching(false);
                      chatProvider.searchList.clear();
                    }
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.grey[200],
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    labelText: 'Search participents',
                    labelStyle: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(
                height: 230,
                width: 260,
                child: Consumer<ChatScreenProvider>(
                    builder: (context, userProvider, child) {
                  return ListView.builder(
                    itemCount: userProvider.isSearching
                        ? userProvider.searchList.length
                        : userProvider.userList.length,
                    itemBuilder: (context, index) {
                      var data = userProvider.isSearching
                          ? userProvider.searchList[index]
                          : userProvider.userList[index];
                      return ListTile(
                        onTap: () {
                          provider.setGroupUsers(data);
                        },
                        leading: Stack(
                          children: [
                            CachedNetworkImage(
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
                            if (provider.groupUsers.contains(data))
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue.withOpacity(0.5),
                                ),
                                child: const Icon(Icons.check,
                                    color: Colors.white),
                              ),
                          ],
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
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 10),
              GestureContainer(
                containerName: 'Close',
                onTap: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ),
      );
    },
  );
}
