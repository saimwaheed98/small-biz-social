import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/models/user_detail_model.dart';
import 'package:smallbiz/screens/users_chat/provider/chat_screen_provider.dart';
import 'package:smallbiz/screens/users_chat/user_chat_widgets/user_chat_container.dart';
import 'package:smallbiz/utils/colors.dart';
import 'package:smallbiz/widgets/app_bar.dart';

class UserChat extends StatelessWidget {
  UserChat({super.key});

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var chatProvider = Provider.of<ChatScreenProvider>(context, listen: false);

    return Scaffold(
      appBar: const ScaffoldAppBar(title: 'Chats'),
      backgroundColor: scaffoldColor,
      body: Padding(
        padding: const EdgeInsets.only(top: 16, right: 24, left: 24),
        child: Column(
          children: [
            SizedBox(
                height: 40,
                child: TextFormField(
                  controller: searchController,
                  style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w400),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    filled: true,
                    fillColor: white,
                    hintText: 'Search',
                    hintStyle: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: primaryTextColor,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xffADB5BD)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(
                            color: Color(0xffFFCBE5), width: 1)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(
                            color: Color(0xffFFCBE5), width: 1)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide.none),
                  ),
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
                )),
            const SizedBox(
              height: 10,
            ),
            Consumer<ChatScreenProvider>(
              builder: (context, provider, child) {
                return StreamBuilder(
                  stream: Apis.getMyUsersId(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          '${snapshot.error}',
                          style: GoogleFonts.dmSans(fontSize: 20),
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          backgroundColor: white,
                          color: primaryPinkColor,
                        ),
                      );
                    }
                    final data = snapshot.data?.docs;
                    provider.setUserList(data
                            ?.map((e) => UserDetail.fromJson(e.data()))
                            .toList() ??
                        []);
                    if (provider.userList.isNotEmpty) {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: provider.isSearching
                              ? provider.searchList.length
                              : provider.userList.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ChatUserContainer(
                                user: provider.isSearching
                                    ? provider.searchList[index]
                                    : provider.userList[index]);
                          },
                        ),
                      );
                    } else {
                      return Center(
                        child: Text(
                          'No Chats Found!',
                          style: GoogleFonts.dmSans(fontSize: 20),
                        ),
                      );
                    }
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
