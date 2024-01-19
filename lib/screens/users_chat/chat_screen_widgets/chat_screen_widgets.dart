import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/helper/text_style.dart';
import 'package:smallbiz/helper/warning_helper.dart';
import 'package:smallbiz/models/post_comment_model.dart';
import 'package:smallbiz/models/post_model.dart';
import 'package:smallbiz/models/user_detail_model.dart';
import 'package:smallbiz/screens/chat_room/model/group_chat_model.dart';
import 'package:smallbiz/screens/user_profile/ui/user_profile_screen.dart';
import 'package:smallbiz/screens/users_chat/provider/chat_screen_provider.dart';
import 'package:smallbiz/utils/colors.dart';
import 'package:smallbiz/utils/date_time.dart';
import 'package:smallbiz/widgets/gesture_container.dart';

class ChatScreenAppBar extends StatefulWidget {
  final UserDetail? user;
  final GroupChatModel? data;
  final PostModel? postData;
  final PostCommentModel? commentUser;
  final bool? isClickAble;
  const ChatScreenAppBar(
      {super.key,
      this.user,
      this.data,
      this.postData,
      this.commentUser,
      this.isClickAble});

  @override
  State<ChatScreenAppBar> createState() => _ChatScreenAppBarState();
}

class _ChatScreenAppBarState extends State<ChatScreenAppBar> {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ChatScreenProvider>(context);
    return AppBar(
      elevation: 0,
      backgroundColor: white,
      title: provider.isSearchingMessage
          ? Consumer<ChatScreenProvider>(
              builder: (context, provider, child) {
                return const SearchFieldMessage();
              },
            )
          : Consumer<ChatScreenProvider>(
              builder: (context, provider, child) {
                return UserDetailsWidget(
                  user: widget.user,
                  data: widget.data,
                  postData: widget.postData,
                  commentUser: widget.commentUser,
                  isClickAble: widget.isClickAble,
                );
              },
            ),
      leading: IconButton(
          onPressed: () {
            setState(() {
              provider.setSearchingMessage(false);
            });
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_outlined,
            color: Color(0xff610030),
          )),
      actions: [
        Consumer<ChatScreenProvider>(
          builder: (context, provider, child) {
            return IconButton(
                onPressed: () {
                  provider.setSearchingMessage(true);
                },
                icon: const Icon(
                  Icons.search,
                  color: black,
                ));
          },
        ),
        PopupMenu(data: widget.data, user: widget.user),
      ],
    );
  }
}

class SearchFieldMessage extends StatefulWidget {
  const SearchFieldMessage({super.key});

  @override
  State<SearchFieldMessage> createState() => _SearchFieldMessageState();
}

class _SearchFieldMessageState extends State<SearchFieldMessage> {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ChatScreenProvider>(context);
    return TextField(
      autofocus: true,
      style: GoogleFonts.actor(
        color: Colors.black,
        fontSize: 18,
      ),
      decoration: const InputDecoration(
        hintText: 'Search by messages...',
        hintStyle: TextStyle(color: Colors.black, fontSize: 13),
        border: InputBorder.none,
      ),
      onChanged: (value) {
        if (value.isNotEmpty) {
          provider.setSearchingMessage(true);
          provider.searchMessageList.clear();
          for (var i in provider.messageList) {
            if (i.message.contains(value)) {
              provider.searchMessageList.add(i);
            }
          }
        } else {
          provider.setSearchingMessage(false);
          provider.searchMessageList.clear();
        }
      },
    );
  }
}

class UserDetailsWidget extends StatelessWidget {
  final UserDetail? user;
  final GroupChatModel? data;
  final PostModel? postData;
  final PostCommentModel? commentUser;
  final bool? isClickAble;
  const UserDetailsWidget(
      {super.key,
      this.user,
      this.data,
      this.postData,
      this.commentUser,
      this.isClickAble});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            if (isClickAble == false) return;
            PersistentNavBarNavigator.pushNewScreen(context,
                screen: UserProfile(
                  user: user,
                  isUser: false,
                ));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextStyle(
                  textName: user?.firstName ??
                      data?.groupName ??
                      postData?.username ??
                      commentUser!.userName,
                  maxLines: 1,
                  textColor: black,
                  textSize: 16,
                  textWeight: FontWeight.w600),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  AppTextStyle(
                      textName: MyDateUtil.getLastActiveTime(
                          context: context,
                          lastActive: user?.lastActive.toString() ?? ''),
                      textColor: black,
                      textSize: 12,
                      textWeight: FontWeight.w300),
                  if (user?.isOnline ?? false)
                    Container(
                      height: 5,
                      width: 5,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.green),
                    )
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}

class PopupMenu extends StatefulWidget {
  final UserDetail? user;
  final GroupChatModel? data;
  const PopupMenu({super.key, this.user, this.data});

  @override
  // ignore: library_private_types_in_public_api
  _PopupMenu createState() => _PopupMenu();
}

class _PopupMenu extends State<PopupMenu> {
  final GlobalKey _popupKey = GlobalKey();

  void _showPopupMenu() {
    final RenderBox popupRenderBox =
        _popupKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        popupRenderBox.localToGlobal(Offset.zero, ancestor: overlay),
        popupRenderBox.localToGlobal(
            popupRenderBox.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      color: const Color(0xffFFD2D4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7),
      ),
      constraints: const BoxConstraints(maxWidth: double.infinity),
      items: [
        if (widget.data?.groupAdmin == Apis.userDetail.uid ||
            widget.user != null)
          PopupMenuItem(
            value: 'delete_chat',
            child: Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                      color: Color(0xffFFBEC1), shape: BoxShape.circle),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: buttonColor,
                    size: 18,
                  ),
                ),
                const SizedBox(
                  width: 7,
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextStyle(
                        textName: 'Delete Chat',
                        textColor: Colors.black,
                        textSize: 16,
                        textWeight: FontWeight.w600),
                  ],
                )
              ],
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return DeletChat(
                    user: widget.user,
                    group: widget.data,
                  );
                },
              );
            },
          ),
        PopupMenuItem(
          value: 'export _chat',
          child: Row(
            children: [
              Container(
                height: 30,
                width: 30,
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(
                    color: Color(0xffFFBEC1), shape: BoxShape.circle),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: buttonColor,
                  size: 18,
                ),
              ),
              const SizedBox(
                width: 7,
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextStyle(
                      textName: 'Export Chat',
                      textColor: Colors.black,
                      textSize: 16,
                      textWeight: FontWeight.w600),
                ],
              )
            ],
          ),
          onTap: () {
            WarningHelper.showProgressDialog(context);
            if (Provider.of<ChatScreenProvider>(context, listen: false)
                .messageList
                .isNotEmpty) {
              Provider.of<ChatScreenProvider>(context, listen: false)
                  .saveChatToFile(
                      Provider.of<ChatScreenProvider>(context, listen: false)
                          .messageList)
                  .then((value) {
                Navigator.of(context).pop();
              });
            } else {
              debugPrint('No messages to save.');
            }
          },
        ),
        // Add more PopupMenuItems as needed
      ],
    ).then((value) {
      if (value != null) {
        // Perform actions based on selected value if needed
        debugPrint('Selected: $value');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        key: _popupKey,
        onPressed: () {
          _showPopupMenu();
        },
        icon: const Icon(
          Icons.more_vert_rounded,
          color: black,
        ));
  }
}

// Alert dialouge to delete that chat

class DeletChat extends StatefulWidget {
  final UserDetail? user;
  final GroupChatModel? group;
  const DeletChat({super.key, this.user, this.group});

  @override
  State<DeletChat> createState() => _DeletChatState();
}

bool isDeleting = false;

class _DeletChatState extends State<DeletChat> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppTextStyle(
                textName: 'Delete Chat',
                textColor: Colors.black,
                textSize: 24,
                textWeight: FontWeight.bold),
            const AppTextStyle(
                textName: 'Are you sure you want to delete this chat?',
                textColor: primaryTextColor,
                textSize: 16,
                textWeight: FontWeight.normal),
            GestureContainer(
                containerName: 'Delet Chat',
                isLoading: isDeleting,
                onTap: () async {
                  setState(() {
                    isDeleting = true;
                  });
                  Apis.deleteChat(group: widget.group, user: widget.user)
                      .then((value) {
                    setState(() {
                      isDeleting = false;
                    });
                    Navigator.pop(context);
                  });
                }),
            GestureContainer(
                containerName: 'Cancel',
                onTap: () {
                  Navigator.pop(context);
                })
          ],
        ),
      ),
    );
  }
}

deletChat({context, UserDetail? user, GroupChatModel? group}) {
  bool isDeleting = false;
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppTextStyle(
                    textName: 'Delete Chat',
                    textColor: Colors.black,
                    textSize: 24,
                    textWeight: FontWeight.bold),
                const AppTextStyle(
                    textName: 'Are you sure you want to delete this chat?',
                    textColor: primaryTextColor,
                    textSize: 16,
                    textWeight: FontWeight.normal),
                GestureContainer(
                    containerName: 'Delet Chat',
                    isLoading: isDeleting,
                    onTap: () async {
                      Apis.deleteChat(group: group, user: user).then((value) {
                        Navigator.pop(context);
                      });
                    }),
                GestureContainer(
                    containerName: 'Cancel',
                    onTap: () {
                      Navigator.pop(context);
                    })
              ],
            ),
          ),
        );
      });
}
