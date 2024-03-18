import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/helper/warning_helper.dart';
import 'package:smallbiz/models/subscription_model.dart';

class ProfileSettingProvider extends ChangeNotifier {
  // get the formkey for the text fields
  final formKey = GlobalKey<FormState>();
  // controller for the text field in the profile setting screen
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController controller = TextEditingController();
  TextEditingController bioController = TextEditingController();

  // dispose the controllers
  disposeControlers() {
    firstNameController.text = '';
    lastNameController.text = '';
    controller.text = '';
    bioController.text = '';
  }

  // bool variable
  bool _isControllerChange = false;
  bool get isControllerChange => _isControllerChange;
  setControllerChange(bool value) {
    _isControllerChange = value;
    notifyListeners();
  }

  // get the user subscription details
  DateTime? _subscriptionEndDate;
  DateTime? get subscriptionEndDate => _subscriptionEndDate;
  setSubscriptionEndDate(DateTime? value) {
    _subscriptionEndDate = value;
    notifyListeners();
  }

  DateTime? _subscriptionStartDate;
  DateTime? get subscriptionStartDate => _subscriptionStartDate;
  setSubscriptionStartDate(DateTime? value) {
    _subscriptionStartDate = value;
    notifyListeners();
  }

  Future<void> getSubscriptionDetails() async {
    await Apis.getSubscriptionDetails().then((value) {
      setSubscriptionEndDate(SubscriptionModel.fromMap(value).endDate);
      setSubscriptionStartDate(SubscriptionModel.fromMap(value).startDate);
      notifyListeners();
      debugPrint('details $subscriptionEndDate');
      debugPrint('details $subscriptionStartDate');
    });
  }
  // check if there is any change happen in the controllers

  onControllerChange() {
    // Update _isControllerChange when any controller changes
    if (lastNameController.text != Apis.userDetail.lastName ||
        firstNameController.text != Apis.userDetail.firstName ||
        bioController.text != Apis.userDetail.bio) {
      setControllerChange(true);
      notifyListeners();
    } else {
      setControllerChange(false);
      notifyListeners();
    }
  }

  // check is uploading image
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  setLoading(bool value) {
    _isLoading = value;
  }

  // get the url for the profile image
  String? _imageUrl;
  String? get imageUrl => _imageUrl;

  getImageUrl(String imageUrl) {
    _imageUrl = imageUrl;
    notifyListeners();
  }

  // update profile picture of user
  Future<String> updateProfilePicture(File file) async {
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
      String imageUrl = await ref.getDownloadURL();
      getImageUrl(imageUrl);
      updateImage();
      notifyListeners(); // notify the listeners
      return imageUrl;
    } catch (e) {
      setLoading(false);
      debugPrint('Error: $e');
      return e.toString();
    } finally {
      setLoading(false);
    }
  }

  // update the profile picture
  Future<void> updateImage() {
    return Apis.firestore
        .collection('users')
        .doc(Apis.userDetail.uid)
        .update({'profilePicture': imageUrl});
  }

  // update the user details
  Future<void> updateDetails() async {
    try {
      setLoading(true);
      notifyListeners(); // notify the listeners
      await Apis.firestore.collection('users').doc(Apis.userDetail.uid).update({
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'bio': bioController.text,
      });
    } catch (e) {
      debugPrint('Error: $e');
      setLoading(false);
      notifyListeners(); // notify the listeners
      WarningHelper.toastMessage(e.toString());
    } finally {
      setLoading(false);
      notifyListeners(); // notify the listeners
    }
  }

  // make the details of the user null
  Future<void> cleanValues() async {
    Apis.userDetail.bio = '';
    Apis.userDetail.firstName = '';
    Apis.userDetail.lastName = '';
    Apis.userDetail.profilePicture = '';
    Apis.userDetail.subscription = false;
    Apis.userDetail.createdAt = '';
    Apis.userDetail.email = '';
    Apis.userDetail.pushToken = '';
    Apis.userDetail.uid = '';
    _subscriptionEndDate = null;
    _subscriptionStartDate = null;
  }
}
