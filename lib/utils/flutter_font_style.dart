import 'package:flutter/material.dart';

import 'Size_config.dart';
import 'flutter_color_themes.dart';

class FTextStyle {

  static TextStyle terms(BuildContext context) => TextStyle(
    fontFamily: 'DM Sans',
    fontWeight: FontWeight.w400,
    fontSize: getResponsiveFontSize(context, 13),
    color:
    Theme.of(context).brightness == Brightness.dark
        ? AppColors.white
        : AppColors.black,
    textBaseline: TextBaseline.alphabetic,
  );

  static TextStyle dashboard(BuildContext context) => TextStyle(
    fontFamily: 'DM Sans',
    fontSize: getResponsiveFontSize(context, 20),
    fontWeight: FontWeight.w600,
    color: Colors.white,
    textBaseline: TextBaseline.alphabetic,
  );

  // Add all font..
  static TextStyle header(BuildContext context) => TextStyle(
    fontFamily: 'NunitoSans',
    fontWeight: FontWeight.w700,
    fontSize: getResponsiveFontSize(context, 16),
    color: AppColors.black,
    textBaseline: TextBaseline.alphabetic,
  );

  static TextStyle appbar(BuildContext context) => TextStyle(
    fontFamily: 'NunitoSans',
    fontSize: getResponsiveFontSize(context, 21),
    fontWeight: FontWeight.w500,
    color: Colors.black, // Keep black for light mode
  );

  // New font styles
  static TextStyle heading1(BuildContext context) => TextStyle(
    fontFamily: 'NunitoSans',
    fontSize: getResponsiveFontSize(context, 24),
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static TextStyle heading2(BuildContext context) => TextStyle(
    fontFamily: 'NunitoSans',
    fontSize: getResponsiveFontSize(context, 20),
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static TextStyle bodyLarge(BuildContext context) => TextStyle(
    fontFamily: 'DM Sans',
    fontSize: getResponsiveFontSize(context, 16),
    fontWeight: FontWeight.w400,
    color: Colors.black87,
  );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
    fontFamily: 'DM Sans',
    fontSize: getResponsiveFontSize(context, 14),
    fontWeight: FontWeight.w400,
    color: Colors.black87,
  );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
    fontFamily: 'DM Sans',
    fontSize: getResponsiveFontSize(context, 12),
    fontWeight: FontWeight.w400,
    color: Colors.black54,
  );

  static TextStyle button(BuildContext context) => TextStyle(
    fontFamily: 'DM Sans',
    fontSize: getResponsiveFontSize(context, 14),
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static TextStyle caption(BuildContext context) => TextStyle(
    fontFamily: 'DM Sans',
    fontSize: getResponsiveFontSize(context, 12),
    fontWeight: FontWeight.w400,
    color: Colors.black54,
  );
  static TextStyle doctorName(BuildContext context) => TextStyle(
    fontFamily: 'NunitoSans',
    fontSize: getResponsiveFontSize(context, 18),
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  static double getResponsiveFontSize(BuildContext context, double size) {
    double textScale = MediaQuery.of(context).textScaleFactor;
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    double baseSize;
    if (isLandscape) {
      baseSize = SizeConfig.screenHeight;
    } else {
      baseSize = SizeConfig.screenWidth;
    }
    return baseSize * 0.0030 * size * textScale;
    // return size * textScale;
  }
}