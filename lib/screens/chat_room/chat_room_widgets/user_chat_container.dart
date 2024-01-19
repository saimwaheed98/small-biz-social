import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/models/chat_model.dart';
import 'package:smallbiz/screens/chat_room/model/group_chat_model.dart';
import 'package:smallbiz/screens/chat_room/provider/chat_room_provider.dart';
import 'package:smallbiz/screens/users_chat/ui/chat_screen.dart';
import 'package:smallbiz/utils/colors.dart';

class UserChatContainer extends StatelessWidget {
  final GroupChatModel data;
  final bool? isClickAble;
  const UserChatContainer({super.key, required this.data, this.isClickAble});

  final bool isOnline = true;

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ChatRoomProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: InkWell(
        onTap: () {
          PersistentNavBarNavigator.pushNewScreen(context,
              withNavBar: false,
              screen: ChatScreen(
                data: data,
                isClickAble: isClickAble,
              ));
        },
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: StreamBuilder(
            stream: Apis.getLastGroupMessage(data),
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
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      const SizedBox(
                        height: 55,
                        width: 55,
                      ),
                      Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: white),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              data.roomImage,
                              fit: BoxFit.cover,
                            ),
                          )),
                      // if the user is online then show the green dot otherwise it will not show
                      if (isOnline == true)
                        Positioned(
                          bottom: 1,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            height: 17,
                            width: 17,
                            decoration: const BoxDecoration(
                              color: white,
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
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              data.groupName,
                              style: GoogleFonts.mulish(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            Consumer<ChatRoomProvider>(
                              builder: (context, provider, child) {
                                final sentTime = provider.message.sent;
                                int parsedSentTime =
                                    0; // Default value if parsing fails

                                try {
                                  parsedSentTime = int.parse(sentTime);
                                } catch (e) {
                                  debugPrint('Error parsing sent time: $e');
                                }

                                final formattedTime =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        parsedSentTime);
                                final formattedHour = formattedTime.hour;
                                final formattedMinute = formattedTime.minute;
                                final isPM = formattedHour >= 12;
                                return Text(
                                  '${formattedHour % 12}:${formattedMinute.toString().padLeft(2, '0')} ${isPM ? 'PM' : 'AM'}',
                                  style: GoogleFonts.mulish(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 170,
                              height: 20,
                              child: Text(
                                provider.message.message.isNotEmpty
                                    ? provider.message.type == Type.image
                                        ? '📷 Image'
                                        : provider.message.type == Type.video
                                            ? '🎥 Video'
                                            : provider.message.type ==
                                                    Type.voice
                                                ? '🎵 Audio'
                                                : provider.message.message
                                    : data.groupDescription,
                                maxLines: 2,
                                style: GoogleFonts.actor(
                                    color: Colors.grey, fontSize: 16),
                              ),
                            ),
                            const Spacer(),
                            // if there is any message from the user only show this container
                            Consumer<ChatRoomProvider>(
                              builder: (context, provider, child) {
                                return provider.unreadMessageCounter > 0
                                    ? Container(
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
                                      )
                                    : const SizedBox(); // Return an empty SizedBox if there are no unread messages
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
