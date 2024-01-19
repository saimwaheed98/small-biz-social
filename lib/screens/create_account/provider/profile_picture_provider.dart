import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smallbiz/helper/firebase_helper.dart';

class ProfilePictureProvider extends ChangeNotifier {
  // set the loading when the image is uploaing
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // for setting the checkbox value
  bool _isChecked = false;
  bool get isChecked => _isChecked;
  void setChecked(bool value) {
    _isChecked = value;
    notifyListeners();
  }

  // for getting the profile picture
  File? _profilePicture;
  File? get profilePicture => _profilePicture;
  final _picker = ImagePicker();

  Future<void>? getProfileImage(ImageSource source) async {
    final pickedFile =
        await _picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      _profilePicture = File(pickedFile.path);
    } else {
      return;
    }
  }

  // update profile picture of user
  Future<void> updateProfilePicture(File file) async {
    //getting image file extension
    try {
      setLoading(true);
      final ext = file.path.split('.').last;
      debugPrint('Extension: $ext');

      //storage file ref with path
      final ref =
          Apis.storage.ref().child('profile_pictures/${Apis.user.uid}.$ext');

      //uploading image
      await ref
          .putFile(file, SettableMetadata(contentType: 'image/$ext'))
          .then((p0) {
        debugPrint('Data Transferred: ${p0.bytesTransferred / 1000} kb');
      });

      //updating image in firestore database
      Apis.userDetail.profilePicture = await ref.getDownloadURL();
      await Apis.firestore
          .collection('users')
          .doc(Apis.user.uid)
          .update({'profilePicture': Apis.userDetail.profilePicture});
    } catch (e) {
      setLoading(false);
      debugPrint('Error: $e');
    }
  }
}
