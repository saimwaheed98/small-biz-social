import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/models/chat_model.dart';
import 'package:smallbiz/models/post_model.dart';
import 'package:smallbiz/providers/bool_function_proider.dart';
import 'package:smallbiz/utils/colors.dart';
import 'package:cached_video_player/cached_video_player.dart';

class VideoPlayerItem extends StatefulWidget {
  final MessageModel? data;
  final PostModel? postData;
  const VideoPlayerItem({Key? key, this.data, this.postData}) : super(key: key);

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late CachedVideoPlayerController _controller;
  late AnimationController _animationController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = CachedVideoPlayerController.network(
        widget.data?.message ?? widget.postData!.postData)
      ..initialize().then((_) {
        setState(() {});
      });
    WidgetsBinding.instance.addObserver(this);
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      if (_controller.value.isPlaying) {
        setState(() {
          _isPlaying = false;
          _controller.pause();
        });
      }
    } else if (state == AppLifecycleState.resumed) {
      if (!_controller.value.isPlaying && _isPlaying) {
        setState(() {
          _isPlaying = true;
          _controller.play();
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<BoolFunctionProvider>(
      context,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: () {
            if (provider.isPlaying) {
              provider.setPlaying(false);
            } else {
              provider.setPlaying(true);
            }
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
          left: 8,
          child: Text(
            (_controller.value.duration).toString().split('.')[0],
            style: const TextStyle(color: Colors.white),
          ),
        ),
        Positioned(
          right: 8,
          bottom: 8,
          child: IconButton(
              onPressed: () {
                _controller.value.volume == 0
                    ? _controller.setVolume(1)
                    : _controller.setVolume(0);
              },
              icon: const Icon(
                Icons.volume_down_rounded,
                color: Colors.white,
              )),
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
        if (provider.isPlaying == false)
          Positioned(
              left: 30,
              child: IconButton(
                  onPressed: () {
                    _controller.seekTo(_controller.value.position -
                        const Duration(seconds: 10));
                  },
                  icon: const Icon(
                    Icons.replay_10_rounded,
                    color: Colors.white,
                    size: 30,
                  ))),
        if (provider.isPlaying == false)
          Positioned(
              right: 30,
              child: IconButton(
                  onPressed: () {
                    _controller.seekTo(_controller.value.position +
                        const Duration(seconds: 10));
                  },
                  icon: const Icon(
                    Icons.forward_10_rounded,
                    color: Colors.white,
                    size: 30,
                  ))),
        if (!_controller.value.isPlaying &&
            !_controller.value.isBuffering &&
            !_isPlaying &&
            provider.isPlaying == false)
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
        if (_controller.value.isPlaying && provider.isPlaying == false)
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
        if (_controller.value.position == _controller.value.duration &&
            provider.isPlaying == false)
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
