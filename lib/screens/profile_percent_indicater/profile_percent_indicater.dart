import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:smallbiz/helper/bottom_bar.dart';
import 'package:smallbiz/helper/text_style.dart';
import 'package:smallbiz/utils/colors.dart';

class ProfilePercentage extends StatefulWidget {
  const ProfilePercentage({Key? key}) : super(key: key);

  static String routeName = '/profile_percentage';

  @override
  State<ProfilePercentage> createState() => _ProfilePercentageState();
}

class _ProfilePercentageState extends State<ProfilePercentage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> animation;
  bool showProfileCreated = false;
  bool showProgress = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    Future.delayed(const Duration(seconds: 3), () {
      _controller.forward();
    });

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, BottomBar.routename);
    });

    animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward().whenComplete(() {
      setState(() {
        showProfileCreated = true;
      });
    });

    // Set up the listener for the animation changes
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      body: Padding(
        padding: const EdgeInsets.only(top: 55, left: 16, right: 16),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppTextStyle(
                textName: 'Create Profile Progressing',
                textColor: Colors.black,
                textSize: 24,
                textWeight: FontWeight.w900,
              ),
              const SizedBox(height: 5),
              const AppTextStyle(
                textName: 'After a few seconds, you can explore our community.',
                textColor: primaryTextColor,
                textSize: 12,
                textWeight: FontWeight.w400,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 120, bottom: 20),
                child: Center(
                  child: Visibility(
                    visible: showProgress,
                    child: CircularPercentIndicator(
                      animation: true,
                      radius: 130.0,
                      lineWidth: 5.0,
                      percent:
                          _controller.value, // Use animation.value (0.0 -> 1.0)
                      center: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(_controller.value * 100).toInt()}%', // Use _controller.value
                            style: GoogleFonts.dmSans(
                              color: buttonColor,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'In Progress Please Wait a moment...',
                            style: GoogleFonts.dmSans(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      progressColor: buttonColor,
                      backgroundColor: Colors.black,
                      onAnimationEnd: () {
                        setState(() {
                          showProgress = false;
                        });
                      },
                    ),
                  ),
                ),
              ),
              Center(
                child: AnimatedOpacity(
                  duration: animation.isCompleted
                      ? const Duration(milliseconds: 5000)
                      : const Duration(milliseconds: 0),
                  opacity: showProfileCreated ? 1.0 : 0.0,
                  child: AnimatedContainer(
                    duration: animation.isCompleted
                        ? const Duration(milliseconds: 1000)
                        : const Duration(milliseconds: 0),
                    curve: Curves.easeInOut,
                    width: showProfileCreated ? 250 : 0,
                    height: showProfileCreated ? 250 : 0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(125),
                      color: buttonColor,
                    ),
                    child: Visibility(
                      visible: showProfileCreated,
                      child: const Center(
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 130,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
