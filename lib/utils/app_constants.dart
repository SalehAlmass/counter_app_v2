import 'package:flutter/material.dart';

class AppConstants {
  // Team names
  static const List<String> defaultTeamNames = [
    "الفريق الأول",
    "الفريق الثاني",
    "الفريق الثالث",
    "الفريق الرابع"
  ];

  // Table dimensions
  static const double tableQuestionColumnWidth = 120.0;
  static const double tableTeamColumnWidth = 100.0;
  static const double tableActionColumnWidth = 80.0;

  // Button sizes
  static const double iconButtonSize = 36.0;

  // Padding
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Text sizes
  static const double headingTextSize = 20.0;
  static const double bodyTextSize = 16.0;
  static const double smallTextSize = 14.0;

  // Game constants
  static const int totalQuestions = 10;

  // Gradient colors
  static const Color winnerGradientStart = Color(0xFF4CAF50);
  static const Color winnerGradientEnd = Color(0xFF2E7D32);
}