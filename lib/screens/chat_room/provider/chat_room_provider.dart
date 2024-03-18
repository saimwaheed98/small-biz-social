import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/models/chat_model.dart';
import 'package:smallbiz/screens/chat_room/model/group_chat_model.dart';

class ChatRoomProvider extends ChangeNotifier {
  // get the url for the groupImage
  String? _imageUrl;
  String? get imageUrl => _imageUrl;

  getImageUrl(String imageUrl) {
    _imageUrl = imageUrl;
    notifyListeners();
  }

  List<GroupChatModel>? groupChatModel;

  /// **********************

// check if the image is uploading
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  setLoading(bool value) {
    _isLoading = value;
  }

  /// **********************

  File? _image;

  File? get image => _image;

  final _picker = ImagePicker();

  void setImage(File? newImage) {
    _image = newImage;
    notifyListeners(); // Notify listeners after updating the image
  }

  /// **********************
  MessageModel message = MessageModel(
    message: '',
    fromId: '',
    sent: '',
    toId: '',
    type: Type.text,
    read: '',
    receiverName: '',
    senderName: '',
  );

  /// **********************
  /// controller for the text field in the chat room screen
  TextEditingController roomNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  /// dispose the controllers
  disposeControlers() {
    roomNameController.text = '';
    descriptionController.text = '';
  }

  // upload audio to firebase
  Future<void> uploadImageToFirebase(
    File? imageFile,
  ) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    var time = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = storage
        .ref()
        .child('groups_data')
        .child('group_image')
        .child('$time.png'); // Define the storage path and file name
    try {
      setLoading(true);
      await ref.putFile(imageFile!);
      String downloadURL = await ref.getDownloadURL();
      getImageUrl(downloadURL);
      notifyListeners();
      debugPrint('File uploaded to Firebase Storage: $downloadURL');
      // You can use the downloadURL for further processing or to store in a database
    } catch (e) {
      setLoading(false);
      debugPrint('Error uploading file to Firebase Storage: $e');
    }
  }

  /// get the image from the gallery
  Future<void> getImage(context, ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      debugPrint('Image Path: ${_image!.path}');
      notifyListeners(); // Notify listeners when the image changes
    } else {
      return;
    }
  }

  // get the counter for the meassage
  int _unreadMessageCounter = 0;
  int get unreadMessageCounter => _unreadMessageCounter;
  setUnreadMessageCounter(int value) {
    _unreadMessageCounter = value;
    notifyListeners();
  }

  Future<void> getUnreadMessageCounter(List<MessageModel> message) async {
    int counter = 0; // Initialize a counter

    for (var i = 0; i < message.length; i++) {
      if (message[i].fromId != Apis.userDetail.uid && message[i].read.isEmpty) {
        counter++; // Increment the counter when the condition is met
      }
    }
    setUnreadMessageCounter(
        counter); // Set the counter value after iterating through all messages
  }
}
