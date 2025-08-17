import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nalsflutter/index.dart';

import 'index.dart';

class TestConfig {
  const TestConfig._();

  static const targetPlatform = TargetPlatform.android;
  static const defaultLocale = Locale('ja');
  static List<LocalizationsDelegate<dynamic>>? additionalLocalizationsDelegate;

  static List<Override> baseOverrides() => [
        analyticsHelperProvider.overrideWith(
          (_) => analyticsHelper,
        ),
        deviceHelperProvider.overrideWith(
          (_) => deviceHelper,
        ),
        isDarkModeProvider.overrideWith((ref) => false),
      ];

  static List<TestDevice> targetGoldenTestDevices({
    List<TestDevice> additionalDevices = const [],
    List<AppTestDeviceType> appDevices = AppTestDeviceType.values,
    bool isTextScaling = false,
  }) {
    final textScale = isTextScaling ? Constant.appMaxTextScaleFactor : 1.0;

    return [
      ...appDevices.map((e) => e.toTestDevice(textScale: textScale)),
      ...additionalDevices,
    ];
  }
}

enum AppTestDeviceType {
  smallPhone(
    size: Size(320, 568),
    name: 'small',
    type: TestDeviceType.smallPhone,
  ),
  tall(
    size: Size(375, 812),
    name: 'tall',
    type: TestDeviceType.phone,
  ),
  wide(
    size: Size(412, 730),
    name: 'wide',
    type: TestDeviceType.phone,
  ),
  tablet(
    size: Size(1024, 1366),
    name: 'tablet',
    type: TestDeviceType.tablet,
  );

  final Size size;
  final String name;
  final TestDeviceType type;

  const AppTestDeviceType({
    required this.size,
    required this.name,
    required this.type,
  });

  TestDevice toTestDevice({
    double textScale = 1.0,
  }) {
    return TestDevice(
      device: Device(
        size: size,
        name: name,
        textScale: textScale,
      ),
      type: type,
    );
  }
}
