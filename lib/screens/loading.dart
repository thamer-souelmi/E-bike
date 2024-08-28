import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:e_bike/screens/scan.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(splash: Column(
      children: [
        Center(
          child: LottieBuilder.asset("assets/Animation.json"),
        )
      ],
    ), nextScreen: const Scan());
  }
}
