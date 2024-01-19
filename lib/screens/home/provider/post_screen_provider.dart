import 'package:flutter/material.dart';
import 'package:smallbiz/helper/firebase_helper.dart';

class PostScreenProvider extends ChangeNotifier {
  bool _replyComment = false;
  bool get replyComment => _replyComment;

  void setReplyComment(bool value) {
    _replyComment = value;
    debugPrint('Reply Comment: $_replyComment');
    notifyListeners();
  }

  // get the lenght of the comments
  int _commentLenght = 0;
  int get commentLenght => _commentLenght;

  getLenth(String postId) {
    Apis.getCommentsLength(postId).then((value) {
      _commentLenght = value;
      notifyListeners();
    });
  }
}
