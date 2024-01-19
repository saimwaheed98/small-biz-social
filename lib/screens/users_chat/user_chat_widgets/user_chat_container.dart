import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:smallbiz/models/user_detail_model.dart';
import 'package:smallbiz/screens/user_profile/ui/user_profile_screen.dart';
import 'package:smallbiz/screens/users_chat/ui/chat_screen.dart';
import 'package:smallbiz/utils/colors.dart';
import 'package:smallbiz/utils/date_time.dart';

class ChatUserContainer extends StatefulWidget {
  final UserDetail user;
  const ChatUserContainer({super.key, required this.user});

  @override
  State<ChatUserContainer> createState() => _ChatUserContainerState();
}

class _ChatUserContainerState extends State<ChatUserContainer> {
  bool isCheck = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (isCheck == true) {
          setState(() {
            isCheck = false;
          });
        } else {
          PersistentNavBarNavigator.pushNewScreen(context,
              withNavBar: false,
              screen: ChatScreen(
                user: widget.user,
              ));
        }
      },
      onLongPress: () {
        // Apis.getMembers(widget.user.uid, [widget.user.uid], context);
        setState(() {
          isCheck = true;
        });
        Clipboard.setData(ClipboardData(text: widget.user.uid));
      },
      child: SizedBox(
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const SizedBox(
                      height: 55,
                      width: 55,
                    ),
                    InkWell(
                      onTap: () {
                        PersistentNavBarNavigator.pushNewScreen(context,
                            withNavBar: false,
                            screen: UserProfile(
                              user: widget.user,
                              isUser: false,
                            ));
                      },
                      child: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: widget.user.profilePicture,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      const SizedBox.shrink(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.person),
                            ),
                          )),
                    ),
                    if (isCheck == true)
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.blue.withOpacity(0.5)),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    // if the user is online then show the green dot otherwise it will not show
                    if (widget.user.isOnline)
                      Positioned(
                        top: 1,
                        right: 1,
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 200,
                        child: Text(
                          '${widget.user.firstName} ${widget.user.lastName}',
                          maxLines: 2,
                          style: GoogleFonts.mulish(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        MyDateUtil.getLastActiveTime(
                            context: context,
                            lastActive: widget.user.lastActive),
                        style: GoogleFonts.mulish(
                            color: buttonColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(color: Color(0xffFAADD4), thickness: 1),
          ],
        ),
      ),
    );
  }
}
