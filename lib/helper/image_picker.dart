import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerProvider extends ChangeNotifier {
  File? _image;

  File? get image => _image;

  final _picker = ImagePicker();

  void setImage(File? newImage) {
    _image = newImage;
    notifyListeners(); // Notify listeners after updating the image
  }

  Future<void> getImage(context, ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      notifyListeners(); // Notify listeners when the image changes
      debugPrint('Image Path: ${_image!.path}');
    } else {
      return;
    }
  }
}
