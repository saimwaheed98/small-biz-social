import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BoolFunctionProvider extends ChangeNotifier {
  bool _isChecked = false;
  bool get isChecked => _isChecked;

  boolFunction(bool isChecked) {
    _isChecked = isChecked;
    notifyListeners();
  }

  // check if the post is liked

  List<String> isLiked = [];
  // List<String> get isLiked => _isLiked;

  // checkIdLiked(String isContain) {
  //   _isLiked.add(isContain);
  //   notifyListeners();
  // }

  // check if the post is starred
  List<String> isStar = [];
  // List<String> get isStar => _isStar;

  // checkIdStar(String isContain) {
  //   _isStar.add(value) = isContain;
  //   notifyListeners();
  // }

  // check if the video is playing or on tap
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  setPlaying(bool value) {
    _isPlaying = value;
    notifyListeners();
  }

  // handle the system channels
  void setupLifecycleListener() {
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (message.toString().contains('resume')) {
        setPlaying(true);
        notifyListeners();
      }
      if (message.toString().contains('pause')) {
        setPlaying(false);
        notifyListeners();
      }
      return Future.value(message);
    });
  }
}
