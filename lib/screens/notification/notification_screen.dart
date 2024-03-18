import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/helper/text_style.dart';
import 'package:smallbiz/models/notification_model.dart';
import 'package:smallbiz/screens/users_chat/provider/chat_screen_provider.dart';
import 'package:smallbiz/utils/colors.dart';
import 'package:smallbiz/utils/date_time.dart';
import 'package:smallbiz/widgets/app_bar.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<ChatScreenProvider>(context, listen: false)
        .checkUserOnlineStatus();
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: const ScaffoldAppBar(title: 'Notifications'),
      body: Column(
        children: [
          StreamBuilder(
            stream: Apis.getNotification(),
            builder: (context, snapshot) {
              if (snapshot.data?.docs.isEmpty ?? true) {
                return const Center(
                  child: AppTextStyle(
                      textName: 'No Notification Yet',
                      textColor: primaryTextColor,
                      textSize: 24,
                      textWeight: FontWeight.w600),
                );
              } else if (snapshot.hasData) {
                var data = snapshot.data?.docs;
                var list = data
                        ?.map((e) => NotificationModel.fromJson(e.data()))
                        .toList() ??
                    [];
                return Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      var data = list[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Container(
                          decoration: BoxDecoration(
                              color: white.withOpacity(0.8),
                              boxShadow: [
                                BoxShadow(
                                    color: black.withOpacity(0.2),
                                    blurRadius: 2,
                                    offset: const Offset(0, 2))
                              ]),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: data.senderImage,
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 30,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: 120,
                                            child: AppTextStyle(
                                                textName: data.title,
                                                textColor: primaryTextColor,
                                                textSize: 20,
                                                maxLines: 1,
                                                textWeight: FontWeight.w400),
                                          ),
                                          const SizedBox(
                                            width: 30,
                                          ),
                                          AppTextStyle(
                                              textName:
                                                  MyDateUtil.getMessageTime(
                                                      context: context,
                                                      time: data.sentAt),
                                              textColor: primaryTextColor,
                                              textSize: 12,
                                              textWeight: FontWeight.w400),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 200,
                                      child: AppTextStyle(
                                          textName: data.message,
                                          textColor: primaryTextColor,
                                          textSize: 16,
                                          maxLines: 1,
                                          textWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          )
        ],
      ),
    );
  }
}
