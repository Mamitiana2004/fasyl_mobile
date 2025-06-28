import 'package:fasyl/core/config/constants.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
        fontFamily: 'Montserrat',
        colorScheme: ColorScheme.dark(
          primary: AppColor.primary,
          secondary: AppColor.secondary,
          surface: AppColor.warmLightSurface,
          error: AppColor.error,
        ));
  }
}
