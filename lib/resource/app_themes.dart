// ignore_for_file: avoid_hard_coded_colors
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../index.dart';

/// define custom themes here
final lightTheme = ThemeData(
  brightness: Brightness.light,
  splashColor: Colors.transparent,
  fontFamily: defaultTargetPlatform == TargetPlatform.android ? FontFamily.notoSansJP : null,
)..addAppColor(
    type: AppThemeType.light,
    appColor: AppColors.defaultAppColor,
  );

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  splashColor: Colors.transparent,
  fontFamily: defaultTargetPlatform == TargetPlatform.android ? FontFamily.notoSansJP : null,
)..addAppColor(
    type: AppThemeType.dark,
    appColor: AppColors.darkThemeColor,
  );

enum AppThemeType { light, dark }

extension ThemeDataExtensions on ThemeData {
  static final Map<AppThemeType, AppColors> _appColorMap = {};

  void addAppColor({
    required AppThemeType type,
    required AppColors appColor,
  }) {
    _appColorMap[type] = appColor;
  }

  AppColors get appColor {
    return _appColorMap[AppTheme.currentAppThemeType] ?? AppColors.defaultAppColor;
  }
}

class AppTheme {
  const AppTheme._();
  static late AppThemeType currentAppThemeType = AppThemeType.light;
}
