import 'package:flutter/material.dart';

class BottomContainer extends StatelessWidget {
  final String containerName;
  final Radius radiusTop;
  final Radius radiusBottom;
  final Radius radiusLeft;
  final Radius radiusRight;
  final VoidCallback onPressed;
  const BottomContainer(
      {super.key,
      required this.containerName,
      required this.radiusTop,
      required this.radiusBottom,
      required this.radiusLeft,
      required this.onPressed,
      required this.radiusRight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Container(
          height: 61,
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: radiusLeft,
                topRight: radiusTop,
                bottomLeft: radiusBottom,
                bottomRight: radiusRight,
              ),
              color: Colors.white),
          child: TextButton(
              onPressed: () => onPressed(),
              child: Text(containerName,
                  style: const TextStyle(fontSize: 20, color: Colors.blue)))),
    );
  }
}