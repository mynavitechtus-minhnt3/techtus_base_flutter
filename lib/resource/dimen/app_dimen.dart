import 'package:flutter/material.dart';

import '../../index.dart';

class AppDimen {
  AppDimen._({
    required this.screenWidth,
    required this.screenHeight,
    required this.devicePixelRatio,
    required this.screenType,
  });

  static late AppDimen current;

  static const maxMobileWidth = 450;
  static const maxTabletWidth = 900;

  final double screenWidth;
  final double screenHeight;
  final double devicePixelRatio;
  final ScreenType screenType;

  static AppDimen init() {
    final size = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
    final devicePixelRatio =
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

    final width = size.width / devicePixelRatio;
    final height = size.height / devicePixelRatio;

    final screen = AppDimen._(
      screenWidth: width,
      screenHeight: height,
      devicePixelRatio: devicePixelRatio,
      screenType: _getScreenType(width),
    );

    current = screen;

    return current;
  }

  double responsiveDimens({
    required double mobile,
    double? tablet,
    double? ultraTablet,
  }) {
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet ?? ((mobile * maxMobileWidth) / Constant.designDeviceWidth);
      case ScreenType.ultraTablet:
        return ultraTablet ?? ((mobile * maxMobileWidth) / Constant.designDeviceWidth);
    }
  }

  int responsiveIntValue({
    required int mobile,
    int? tablet,
    int? ultraTablet,
  }) {
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.ultraTablet:
        return ultraTablet ?? mobile;
    }
  }

  static ScreenType _getScreenType(double screenWidth) {
    if (screenWidth <= maxMobileWidth) {
      return ScreenType.mobile;
    } else if (screenWidth <= maxTabletWidth) {
      return ScreenType.tablet;
    } else {
      return ScreenType.ultraTablet;
    }
  }
}

extension ResponsiveDoubleExtension on num {
  double responsive({
    double? tablet,
    double? ultraTablet,
  }) {
    return AppDimen.current.responsiveDimens(
      mobile: toDouble(),
      tablet: tablet,
      ultraTablet: ultraTablet,
    );
  }

  double get rps {
    return responsive();
  }
}

enum ScreenType {
  mobile,
  tablet,
  ultraTablet,
}
