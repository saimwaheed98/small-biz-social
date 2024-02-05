import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/helper/warning_helper.dart';
import 'package:smallbiz/models/chat_model.dart';
import 'package:smallbiz/models/post_comment_model.dart';
import 'package:smallbiz/models/post_model.dart';
import 'package:smallbiz/models/user_detail_model.dart';
import 'package:smallbiz/screens/chat_room/model/group_chat_model.dart';
import 'package:text2pdf/text2pdf.dart';
import 'package:video_compress/video_compress.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart' as path_provider;

class ChatScreenProvider extends ChangeNotifier {
  // preview the link of the image
  var data;
  get getData => data;
  void setData(value) {
    data = value;
    notifyListeners();
  }

  // for getting the value for the searching
  bool _isSearching = false;
  bool get isSearching => _isSearching;

  setSearching(bool value) {
    _isSearching = value;
    notifyListeners();
  }

  // audio file path
  File? _audioPath;
  File? get audioPath => _audioPath;
  void setAudioPath(File audioPath) {
    _audioPath = audioPath;
    notifyListeners();
  }

  bool _isRecording = false;
  bool get isRecording => _isRecording;
  setRecording(bool value) {
    _isRecording = value;
    notifyListeners();
  }

  // for getting the value of users for the searching
  List<UserDetail> searchList = [];
  List<UserDetail> userList = [];

  // for getting the value of the messages for the searching
  bool _isSearchingMessage = false;
  bool get isSearchingMessage => _isSearchingMessage;

  void setSearchingMessage(bool value) {
    _isSearchingMessage = value;
    notifyListeners();
  }

  List<MessageModel> searchMessageList = [];
  List<MessageModel> messageList = [];

  // for getting the value for the recording
  final recoder = FlutterSoundRecorder();
  bool isRecorderReady = false;

  Future record() async {
    if (!isRecorderReady) return;
    setRecording(true);
    await recoder.startRecorder(toFile: 'audio');
  }

  Future<void> stop(UserDetail? user, GroupChatModel? group,
      PostModel? postData, PostCommentModel? commentUser) async {
    if (!isRecorderReady) return;
    final path = await recoder.stopRecorder();
    debugPrint('File path: $path');
    _audioPath = File(path!);
    setRecording(false);
    // await uploadAudioToFirebase(file, user, group, postData, commentUser);
  }

  // upload audio to firebase
  Future<void> uploadAudioToFirebase(
      File audioFile,
      UserDetail? user,
      GroupChatModel? group,
      PostModel? postData,
      PostCommentModel? commentUser) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    var time = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = storage
        .ref()
        .child('audio')
        .child(
            user?.uid ?? group?.groupId ?? postData?.uid ?? commentUser!.fromId)
        .child('$time.aac'); // Define the storage path and file name
    try {
      setUploading(true);
      await ref.putFile(audioFile);
      String downloadURL = await ref.getDownloadURL();
      await Apis.sendMessage(
          user, group, postData, commentUser, downloadURL, Type.voice);
      debugPrint('File uploaded to Firebase Storage: $downloadURL');
      // You can use the downloadURL for further processing or to store in a database
    } catch (e) {
      setUploading(false);
      debugPrint('Error uploading file to Firebase Storage: $e');
    }
  }

  initializedRecorder() {
    initRecoder();
    notifyListeners();
  }

  closeRecorder() {
    recoder.closeRecorder();
    notifyListeners();
  }

  // initalize the then it will work
  Future initRecoder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }
    await recoder.openRecorder();
    isRecorderReady = true;
    recoder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  /// get the vlaue for video

  // checking the user is playing the video or not
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  setPlaying(bool value) {
    _isPlaying = value;
    notifyListeners();
  }

  // for getting the video from the gellery
  final _imagePicker = ImagePicker();
  File? _video;
  File? get video => _video;

  void setVideo(File? video) {
    _video = video;
    notifyListeners();
  }

  // for getting the url of the video
  String? _videoUrl;
  String? get videoUrl => _videoUrl;
  void setVideoUrl(String? videoUrl) {
    _videoUrl = videoUrl;
    notifyListeners();
  }

  // check if the video is uploading
  bool _isUploading = false;
  bool get isUploading => _isUploading;
  void setUploading(bool value) {
    _isUploading = value;
    notifyListeners();
  }

  // get video from the gallery
  Future<void> getVideo(UserDetail? user, GroupChatModel? group) async {
    final pickedFile =
        await _imagePicker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setVideo(File(pickedFile.path));
      notifyListeners();
      // await uploadVideoToFirebase(video, user, group);
    } else {
      return;
    }
  }

  // upload audio to firebase
  Future<void> uploadVideoToFirebase(
      File? videoFile,
      UserDetail? user,
      GroupChatModel? group,
      PostModel? postUser,
      PostCommentModel? commentUser,
      context) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    var time = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      setUploading(true);
      MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        videoFile!.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false, // It's false by default
      );
      Reference ref = storage
          .ref()
          .child('chat_video')
          .child(user?.uid ??
              group?.groupId ??
              postUser?.uid ??
              commentUser!.fromId)
          .child('$time.mp4'); // Define the storage path and file name

      await ref.putFile(mediaInfo!.file!);
      String downloadURL = await ref.getDownloadURL();
      setVideoUrl(downloadURL);
      notifyListeners();
      // await Apis.sendMessage(user, group, downloadURL, Type.video);
      debugPrint('File uploaded to Firebase Storage: $downloadURL');
      // You can use the downloadURL for further processing or to store in a database
    } catch (e) {
      setUploading(false);
      notifyListeners();
      WarningHelper.showWarningDialog(context, 'Error', e.toString());
      debugPrint('Error uploading file to Firebase Storage: $e');
    } finally {
      setUploading(false);
      notifyListeners();
    }
  }

  // get the url of the image
  String? _imageUrl;
  String? get imageUrl => _imageUrl;
  void setImageUrl(String? imageUrl) {
    _imageUrl = imageUrl;
    notifyListeners();
  }

  // upload image to storage
  Future<String> uploadImageToFirebase(
      File? imageFile,
      UserDetail? user,
      GroupChatModel? group,
      PostModel? postData,
      PostCommentModel? commentUser) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    var time = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = storage
        .ref()
        .child('chat_image')
        .child(
            user?.uid ?? group?.groupId ?? postData?.uid ?? commentUser!.fromId)
        .child('$time.png'); // Define the storage path and file name
    try {
      setUploading(true);
      notifyListeners();
      await ref.putFile(imageFile!);
      String downloadURL = await ref.getDownloadURL();
      setImageUrl(downloadURL);
      notifyListeners();
      return downloadURL;
      // You can use the downloadURL for further processing or to store in a database
    } catch (e) {
      setUploading(false);
      notifyListeners();
      debugPrint(e.toString());
      return '';
    } finally {
      setUploading(false);
      notifyListeners();
    }
  }

  // check the user online or not
  checkUserOnlineStatus() {
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (Apis.auth.currentUser != null) {
        debugPrint('SystemChannels> $message');
        if (message.toString().contains('resume')) {
          Apis.updateActiveStatus(true);
        } else if (message.toString().contains('pause')) {
          Apis.updateActiveStatus(false);
        } else if (message.toString().contains('inactive')) {
          // Handle inactive state (if needed)
          Apis.updateActiveStatus(false);
        } else if (message.toString().contains('detached')) {
          // Handle detached state (if needed)
          Apis.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  Future<void> saveChatToFile(List<MessageModel> messages) async {
    try {
      // Creating a Map to group messages by sender
      Map<String, List<String>> chatMap = {};

      // Grouping messages by sender names
      for (var message in messages) {
        String senderName = message.senderName;

        // Storing messages with sender names
        if (!chatMap.containsKey(senderName)) {
          chatMap[senderName] = [];
        }
        chatMap[senderName]!.add(message.message);
      }

      // Get the directory for storing the file
      Directory? directory = await path_provider.getDownloadsDirectory();
      File file = File('${directory!.path}/chat_data.txt');
      IOSink sink = file.openWrite();

      // Writing messages to the file
      chatMap.forEach((name, messages) {
        sink.write("$name:\n");
        for (var msg in messages) {
          sink.write("  $msg\n");
        }
        sink.write("\n");
      });

      await sink.flush();
      await sink.close();

      await Text2Pdf.generatePdf(file.readAsStringSync(),
          outputFilePath: '${directory.path}/chat_data.pdf');
      WarningHelper.toastMessage('Chat data saved to ${file.path}');
      debugPrint('Chat data saved to ${file.path}');
    } catch (e) {
      // Handle errors, if any
      debugPrint('Error saving chat data: $e');
      WarningHelper.toastMessage('Error saving chat data');
    }
  }
}
