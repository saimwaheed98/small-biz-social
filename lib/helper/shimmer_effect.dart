import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AvatarLoading extends StatelessWidget {
  final double radius;
  const AvatarLoading({super.key, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.white,
        highlightColor: Colors.grey.shade200,
        child: CircleAvatar(
          radius: radius,
        ));
  }
}

class ImageLoading extends StatelessWidget {
  final double height;
  final double width;
  const ImageLoading({super.key,required this.height,required this.width});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.white,
        highlightColor: Colors.grey.shade200,
        child: SizedBox(
          height: height,
          width: width,

        ));
  }
}
