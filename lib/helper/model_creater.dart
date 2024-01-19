import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smallbiz/helper/firebase_helper.dart';

class ModelCreater extends StatefulWidget {
  const ModelCreater({super.key});

  @override
  State<ModelCreater> createState() => _ModelCreaterState();
}

class _ModelCreaterState extends State<ModelCreater> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: Apis.firestore.collection('posts').snapshots(),
        builder: (context, snapshot) {
          final list = [];
          if (snapshot.hasData) {
            final data = snapshot.data?.docs;
            for (var i in data!) {
              debugPrint('data is ${jsonEncode(i.data())}');
              list.add(i.data()['firstname']);
            }
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(list[index]),
              );
            },
          );
        },
      ),
    );
  }
}
