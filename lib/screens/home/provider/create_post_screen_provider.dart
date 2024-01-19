import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/helper/warning_helper.dart';
import 'package:video_compress/video_compress.dart';

class CreatePostScreenProvider extends ChangeNotifier {
  /// check the image and the video is uploaded or not
  /// if uploaded then upload the post
  bool _isUploading = false;
  bool get isUploading => _isUploading;

  void isUploadingPost(bool value) {
    _isUploading = value;
    notifyListeners();
  }

  // check that how much data is uploaded
  double _transferData = 0.0;
  double get transferData => _transferData;

  void checkTransferdData(double value) {
    _transferData = value;
    notifyListeners();
  }

  /// **************** image **********************
  File? image;
  String? url;
  final _imagePicker = ImagePicker();

  void setImage(File? image) {
    this.image = image;
    notifyListeners();
  }

  void setImageUrl(String url) {
    this.url = url;
    notifyListeners();
  }

  void removeImage() {
    image = null;
    notifyListeners();
  }

  Future<void> pickImage(context) async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setImage(File(pickedFile.path));
      notifyListeners();
      WarningHelper.showWarningDialog(
          context, 'Success', 'Image Picked Successfully');
    } else {
      return;
    }
  }

  //Get image url
  Future<String?> getPostImageUrl(context) async {
    try {
      isUploadingPost(true);
      //getting image file extension
      final ext = image!.path.split('.').last;

      //storage file ref with path
      final ref = Apis.storage.ref().child(
          'posts/${Apis.userDetail.uid}/${DateTime.now().millisecondsSinceEpoch}.$ext');

      //uploading image
      await ref
          .putFile(image!, SettableMetadata(contentType: 'image/$ext'))
          .then((p0) {
        checkTransferdData(p0.bytesTransferred / 1000);
        log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
      });

      //updating image in firestore database
      var imageUrl = await ref.getDownloadURL();
      setImageUrl(imageUrl);
      notifyListeners();
      return imageUrl;
    } catch (e) {
      checkTransferdData(0.0);
      isUploadingPost(false);
      WarningHelper.showWarningDialog(context, 'Error', e.toString());
      log(e.toString());
      return e.toString();
    } finally {
      checkTransferdData(0.0);
      isUploadingPost(false);
    }
  }

  /// **************** Video**********************

  File? video;
  String? videoUrl;

  void setVideo(File? video) {
    this.video = video;
    notifyListeners();
  }

  void setVideoUrl(String url) {
    videoUrl = url;
    notifyListeners();
  }

  void removeVideo() {
    video = null;
    notifyListeners();
  }

  Future<void> pickVideo(context) async {
    final pickedFile =
        await _imagePicker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setVideo(File(pickedFile.path));
      WarningHelper.showWarningDialog(
          context, 'Success', 'Video Picked Successfully');
    } else {
      return;
    }
  }

  //Get Video url
  Future<String?> getPostVideoUrl(context) async {
    try {
      isUploadingPost(true);
      //getting image file extension
      final ext = video!.path.split('.').last;

      MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        video!.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false, // It's false by default
      );

      //storage file ref with path
      final ref = Apis.storage.ref().child(
          'posts/${Apis.userDetail.uid}/${DateTime.now().millisecondsSinceEpoch}.$ext');

      //uploading image
      await ref
          .putFile(
              mediaInfo!.file!, SettableMetadata(contentType: 'video/$ext'))
          .then((p0) {
        checkTransferdData(p0.bytesTransferred / 1000);
        log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
      });

      //updating image in firestore database
      var videoUrl = await ref.getDownloadURL();
      setVideoUrl(videoUrl);
      notifyListeners();
      return videoUrl;
    } catch (e) {
      checkTransferdData(0.0);
      isUploadingPost(false);
      WarningHelper.showWarningDialog(context, 'Error', e.toString());
      log(e.toString());
      return e.toString();
    } finally {
      checkTransferdData(0.0);
      isUploadingPost(false);
    }
  }
}
