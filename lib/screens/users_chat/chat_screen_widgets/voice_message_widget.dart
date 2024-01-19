import 'package:flutter/material.dart';
import 'package:smallbiz/utils/colors.dart';
import 'package:voice_message_package/voice_message_package.dart';

class VoiceMessageChat extends StatelessWidget {
  final String message;
  final bool isFile;
  const VoiceMessageChat(
      {super.key, required this.message, required this.isFile});

  @override
  Widget build(BuildContext context) {
    return VoiceMessageView(
      activeSliderColor: Colors.white,
      circlesColor: buttonColor,
      backgroundColor: buttonColor,
      controller: VoiceController(
        audioSrc: message,
        maxDuration: const Duration(seconds: 120),
        isFile: isFile,
        onComplete: () {
          debugPrint('onComplete');
        },
        onPause: () {
          debugPrint('onPause');
        },
        onPlaying: () {
          debugPrint('onPlaying');
        },
      ),
      innerPadding: 12,
      cornerRadius: 20,
    );
  }
}
