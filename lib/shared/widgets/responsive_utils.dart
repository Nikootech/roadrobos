import 'package:flutter/material.dart';

class ResponsiveLayout {
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static bool isSmallPhone(BuildContext context) => screenWidth(context) <= 360;
  static bool isMediumPhone(BuildContext context) =>
      screenWidth(context) > 360 && screenWidth(context) <= 414;
  static bool isLargePhone(BuildContext context) =>
      screenWidth(context) > 414 && screenWidth(context) <= 600;
  static bool isTablet(BuildContext context) => screenWidth(context) > 600;

  static double responsiveWidth(BuildContext context, double p) =>
      screenWidth(context) * (p / 100);
  static double responsiveHeight(BuildContext context, double p) =>
      screenHeight(context) * (p / 100);

  // New method to match usage
  static EdgeInsets responsivePadding(BuildContext context,
      {double horizontal = 24.0, double vertical = 0.0}) {
    double h = horizontal * (screenWidth(context) / 375);
    double v = vertical * (screenWidth(context) / 375);
    if (isTablet(context)) {
      h *= 1.5;
      v *= 1.5;
    }
    return EdgeInsets.symmetric(horizontal: h, vertical: v);
  }

  // New method to match usage
  static double responsiveFontSize(BuildContext context, double baseSize) {
    double scale = screenWidth(context) / 375;
    if (isTablet(context)) scale = 1.25;
    if (isSmallPhone(context)) scale = 0.9;
    return baseSize * scale;
  }

  static double padding(BuildContext context) {
    if (isSmallPhone(context)) return 16.0;
    if (isTablet(context)) return 32.0;
    return 24.0;
  }

  static double fontSize(BuildContext context, double baseSize) {
    return responsiveFontSize(context, baseSize);
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: style?.copyWith(
        fontSize: ResponsiveLayout.fontSize(context, style?.fontSize ?? 14.0),
      ),
    );
  }
}
