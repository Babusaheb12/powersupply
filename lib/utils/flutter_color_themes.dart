import 'package:flutter/material.dart';

class AppColors extends MaterialColor {
  const AppColors(super.primary, super.swatch);
  static const Color grey100 = Color(0xFFF1F0F3);
  static const Color grey300 = Color(0xFFE0E0E0); // new
  static const Color grey400 = Color(0xFFBDBDBD); // new
  static const Color texFiled = Color(0xFF64748B);
  static const Color iconColor = Color(0xFF333333);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF); // --White
  static const Color bottomNavBar = Color(0xFF8B8A9E); // grey500, #8B8A9E
  static const Color sortFilterbg = Color(0xFF434343); // dark-mode-BNB, #434343
  static const Color sortFilterBoarder = Color(0xFFD1D1D1); // --Tertiary-text
  static const Color searchBoxContainer = Color(0xFF030E1E); // dark-mode-input
  static const Color searchBoxBoarder = Color(0xFFB3C5D4); // light-grey-blue400
  static const Color almostWhite = Color(0xFFFCFCFC);
  static const Color selectFileLightBg = Color(0xFFFAFAFA);
  static const Color orangeRED = Color(0xFFFA6232,); // Assuming this is the intended formate
  static const Color lightGrey = Color(0xFFE8E8E8); // solid, #E8E8E8

  // Gradient Colors
  static const gradientStart = Color(0xFFFF9700); // #FF9700
  static const gradientMiddle = Color(0xFFFF6C00); // #FF6C00
  static const gradientEnd = Color(0xFFFA6232); // #FA6232
  static const Color editBtn = Color(0xFF1573FE); // Accent blue

  /// App colors


  static const Color appBarColor = Color(0xFFE3F2FD);
  static const Color primaryBlue = Color(0xFF2196F3);

  static const LinearGradient linearGradient1 = LinearGradient(
    colors: [Color(0xFFFA6232), Color(0xFFF9A826)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Predefined Linear Gradient
  static const LinearGradient linearGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [gradientStart, gradientMiddle, gradientEnd],
    stops: [0.0, 0.525, 1.0],
  );


}
