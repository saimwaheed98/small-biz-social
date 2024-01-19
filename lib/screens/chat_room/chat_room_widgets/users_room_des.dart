import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/models/chat_model.dart';
import 'package:smallbiz/screens/chat_room/model/group_chat_model.dart';
import 'package:smallbiz/screens/chat_room/provider/chat_room_provider.dart';
import 'package:smallbiz/utils/colors.dart';

class UserRoomContainer extends StatelessWidget {
  final GroupChatModel groupData;
  const UserRoomContainer({super.key, required this.groupData});

  @override
  Widget build(BuildContext context) {
     var provider = Provider.of<ChatRoomProvider>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 7, right: 7),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox(
                height: 55,
                width: 55,
              ),
              StreamBuilder(
                stream: Apis.getLastGroupMessage(groupData),
                builder: (context, snapshot) {
                  final messageData = snapshot.data?.docs;
                  final list = messageData
                          ?.map((e) => MessageModel.fromJson(e.data()))
                          .toList() ??
                      [];
                  if (list.isNotEmpty) {
                    provider.message = list[0];
                  }
                  Provider.of<ChatRoomProvider>(context, listen: false)
                      .getUnreadMessageCounter(list);
                  return Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: groupData.roomImage,
                        errorWidget: (context, url, error) {
                          return const Icon(Icons.error_outline);
                        },
                        placeholder: (context, url) {
                          return Shimmer.fromColors(
                            baseColor: Colors.white,
                            highlightColor: Colors.grey,
                            child: Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                          );
                        },
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
              // if there is any message from the user only show this container
              // if (message?.fromId != Apis.userDetail.uid &&
              //     message!.read.isEmpty)
              Consumer<ChatRoomProvider>(
                builder: (context, provider, child) {
                  return provider.unreadMessageCounter > 0
                      ? Positioned(
                          top: 1,
                          right: 1,
                          child: Container(
                            alignment: Alignment.center,
                            height: 20,
                            width: 20,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xffE94242)),
                            child: Text(
                              '${provider.unreadMessageCounter}',
                              style: GoogleFonts.mulish(
                                  color: white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        )
                      : const SizedBox(); // Return an empty SizedBox if there are no unread messages
                },
              ),
              // if the user is online only show that container
              Positioned(
                bottom: 1,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  height: 17,
                  width: 17,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    height: 12,
                    width: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xff2CC069),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          groupData.groupName,
          style: GoogleFonts.mulish(fontSize: 10, fontWeight: FontWeight.w400),
        )
      ],
    );
  }
}
