import 'package:flutter/material.dart';

/// Helper utilities for responsive layout calculations.
class ResponsiveHelper {
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  static bool isWideScreen(BuildContext context) =>
      MediaQuery.of(context).size.width > tabletBreakpoint;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static EdgeInsets responsivePadding(BuildContext context) {
    if (isMobile(context)) return const EdgeInsets.all(12);
    if (isTablet(context)) return const EdgeInsets.all(16);
    return const EdgeInsets.all(24);
  }

  static double responsiveFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) return baseFontSize * 0.9;
    if (isTablet(context)) return baseFontSize;
    return baseFontSize * 1.1;
  }

  static int responsiveColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }

  static BoxConstraints responsiveConstraints(BuildContext context) {
    final width = screenWidth(context);

    if (isMobile(context)) {
      return BoxConstraints(maxWidth: width * 0.95, minHeight: 200);
    }
    if (isTablet(context)) {
      return BoxConstraints(maxWidth: width * 0.9, minHeight: 250);
    }
    return BoxConstraints(maxWidth: width * 0.8, minHeight: 300);
  }

  static double responsiveCardHeight(BuildContext context) {
    if (isMobile(context)) return 200;
    if (isTablet(context)) return 250;
    return 300;
  }
}