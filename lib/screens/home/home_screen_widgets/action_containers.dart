import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/helper/text_style.dart';
import 'package:smallbiz/models/post_model.dart';
import 'package:smallbiz/screens/home/provider/home_screen_provider.dart';
import 'package:smallbiz/utils/colors.dart';

class LikeButton extends StatefulWidget {
  final PostModel data;
  final int index;
  const LikeButton({super.key, required this.data, required this.index});

  @override
  State<LikeButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  bool isFav = false;
  AnimationController? controller;
  Animation<Color?>? colorAnimation;
  Animation<double>? sizeAnimation;
  Animation<double>? curve;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    sizeAnimation = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem(tween: Tween<double>(begin: 30, end: 60), weight: 300),
      TweenSequenceItem(tween: Tween<double>(begin: 60, end: 30), weight: 300),
    ]).animate(controller!);

    curve = CurvedAnimation(parent: controller!, curve: Curves.elasticIn);
    colorAnimation =
        ColorTween(begin: Colors.black, end: Colors.blue).animate(curve!);
    controller!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isFav = true;
        });
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          isFav = false;
        });
      }
    });
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isContain = widget.data.likes.contains(Apis.user.uid);
    var homeProvider = Provider.of<HomeScreenProvider>(context, listen: false);
    return InkWell(
      onTap: () async {
        homeProvider.updatePostLikes(widget.data, widget.index);
        await Apis.likePost(widget.data.postId, widget.data.likes, context);
        isFav ? controller!.reverse() : controller!.forward();
      },
      child: SizedBox(
        height: 70,
        width: MediaQuery.of(context).size.width * 0.25,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: controller!,
              builder: (context, child) {
                return Icon(
                  isFav || isContain
                      ? Icons.thumb_up_alt_rounded
                      : Icons.thumb_up_alt_outlined,
                  size: sizeAnimation!.value,
                  color: colorAnimation!.value,
                );
              },
            ),
            const SizedBox(
              width: 5,
            ),
            const AppTextStyle(
              textName: 'Like',
              textColor: primaryTextColor,
              textSize: 11,
              textWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }
}

class StarButton extends StatefulWidget {
  final PostModel data;
  final int index;
  const StarButton({super.key, required this.data, required this.index});

  @override
  State<StarButton> createState() => _StarButtonState();
}

class _StarButtonState extends State<StarButton>
    with SingleTickerProviderStateMixin {
  bool isFav = false;
  AnimationController? controller;
  Animation<Color?>? colorAnimation;
  Animation<double>? sizeAnimation;
  Animation<double>? curve;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    sizeAnimation = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem(tween: Tween<double>(begin: 30, end: 60), weight: 300),
      TweenSequenceItem(tween: Tween<double>(begin: 60, end: 30), weight: 300),
    ]).animate(controller!);

    curve = CurvedAnimation(parent: controller!, curve: Curves.elasticIn);
    colorAnimation =
        ColorTween(begin: Colors.black, end: Colors.orange).animate(curve!);
    controller!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isFav = true;
        });
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          isFav = false;
        });
      }
    });
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isContain = widget.data.stars.contains(Apis.user.uid);
    var homeProvider = Provider.of<HomeScreenProvider>(context, listen: false);
    return InkWell(
      onTap: () {
        homeProvider.updatePostStars(widget.data, widget.index);
        Apis.starPost(widget.data.postId, widget.data.stars, context);
        isFav ? controller!.reverse() : controller!.forward();
      },
      child: SizedBox(
        height: 70,
        width: MediaQuery.of(context).size.width * 0.25,
        child: Row(
          children: [
            AnimatedBuilder(
              animation: controller!,
              builder: (context, child) {
                return Icon(
                  isFav || isContain
                      ? Icons.star_rate_rounded
                      : Icons.star_border_rounded,
                  size: sizeAnimation!.value,
                  color: colorAnimation!.value,
                );
              },
            ),
            const SizedBox(
              width: 5,
            ),
            const AppTextStyle(
              textName: 'Favorite',
              textColor: primaryTextColor,
              textSize: 11,
              textWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }
}
