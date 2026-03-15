
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SizeConfig {
  static late double screenWidth;
  static late double screenHeight;
  static late double scaleWidth;
  static late double scaleHeight;

  static const double baseWidth = 375.0;  // Base width for scaling (iPhone X)
  static const double baseHeight = 812.0; // Base height for scaling (iPhone X)

  static late TargetPlatform platform;

  /// Initialize for mobile using context (iOS / Android)
  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    scaleWidth = screenWidth / baseWidth;
    scaleHeight = screenHeight / baseHeight;

    // Detect current platform
    if (kIsWeb) {
      platform = TargetPlatform.android; // You can customize default for web
    } else {
      platform = Theme.of(context).platform;
    }
  }

  /// Use this for Flutter Web (from `main_web.dart`)
  static void initWithDimensions({
    required double screenWidth,
    required double screenHeight,
  }) {
    SizeConfig.screenWidth = screenWidth;
    SizeConfig.screenHeight = screenHeight;
    scaleWidth = screenWidth / baseWidth;
    scaleHeight = screenHeight / baseHeight;

    platform = TargetPlatform.android; // Default platform for web
  }

  static double scaleW(double width) => width * scaleWidth;
  static double scaleH(double height) => height * scaleHeight;

  static bool get isIOS => !kIsWeb && platform == TargetPlatform.iOS;
  static bool get isAndroid => !kIsWeb && platform == TargetPlatform.android;
  static bool get isWeb => kIsWeb;

}
