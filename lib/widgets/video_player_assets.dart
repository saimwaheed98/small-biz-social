import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smallbiz/utils/colors.dart';
import 'package:cached_video_player/cached_video_player.dart';

class VideoPlayerItem extends StatefulWidget {
  final File videoData;
  const VideoPlayerItem({Key? key, required this.videoData}) : super(key: key);

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem>
    with SingleTickerProviderStateMixin {
  late CachedVideoPlayerController _controller;
  late AnimationController _animationController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = CachedVideoPlayerController.file(widget.videoData)
      ..initialize().then((_) {
        setState(() {});
      });

    _controller.addListener(() {
      if (!_controller.value.isPlaying &&
          !_controller.value.isBuffering &&
          _controller.value.position == _controller.value.duration) {
        setState(() {
          _isPlaying = false;
        });
      }
    });

    _animationController = AnimationController(
      vsync: this,
      value: 0,
      duration: _controller.value.duration,
    );

    _controller.addListener(() {
      final position = _controller.value.position.inMilliseconds.toDouble();
      final duration = _controller.value.duration.inMilliseconds.toDouble();
      _animationController.value = position / duration;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isPlaying = !_isPlaying;
              if (_isPlaying) {
                _controller.play();
              } else {
                _controller.pause();
              }
            });
          },
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _controller.value.isInitialized
                ? CachedVideoPlayer(_controller)
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Text(
            (_controller.value.duration).toString().split('.')[0],
            style: const TextStyle(color: Colors.white),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 4,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _animationController.value,
                  minHeight: 6,
                  backgroundColor: Colors.grey[400],
                  valueColor: AlwaysStoppedAnimation<Color?>(
                    ColorTween(
                      begin: Colors.red,
                      end: buttonColor,
                    ).evaluate(
                        AlwaysStoppedAnimation(_animationController.value)),
                  ),
                );
              },
            ),
          ),
        ),
        if (!_controller.value.isPlaying &&
            !_controller.value.isBuffering &&
            !_isPlaying)
          IconButton(
            onPressed: () {
              setState(() {
                _isPlaying = true;
                _controller.play();
              });
            },
            icon: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 30,
            ),
          ),
        if (_controller.value.isBuffering) const CircularProgressIndicator(),
        if (_controller.value.isPlaying)
          IconButton(
            onPressed: () {
              setState(() {
                _isPlaying = false;
                _controller.pause();
              });
            },
            icon: const Icon(
              Icons.pause,
              color: Colors.white,
              size: 30,
            ),
          ),
        if (!_controller.value.isPlaying &&
            !_controller.value.isBuffering &&
            !_isPlaying &&
            _controller.value.position == _controller.value.duration)
          IconButton(
            onPressed: () {
              setState(() {
                _controller.seekTo(Duration.zero);
                _isPlaying = true;
                _controller.play();
              });
            },
            icon: const Icon(
              Icons.replay_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
      ],
    );
  }
}
