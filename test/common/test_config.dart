import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:nalsflutter/index.dart';

import 'index.dart';

class TestConfig {
  const TestConfig._();

  static const targetPlatform = TargetPlatform.android;
  static const l10nTestLocale = Locale('ja');
  static List<LocalizationsDelegate<dynamic>>? additionalLocalizationsDelegate;

  static final baseOverrides = [
    analyticsHelperProvider.overrideWith(
      (_) => analyticsHelper,
    ),
    deviceHelperProvider.overrideWith(
      (_) => deviceHelper,
    ),
  ];

  static List<TestDevice> targetGoldenTestDevices({
    List<TestDevice> additionalDevices = const [],
    bool isTextScaling = false,
  }) {
    final textScale = isTextScaling ? Constant.appMaxTextScaleFactor : 1.0;

    return [
      TestDevice(
        device: Device(size: const Size(320, 568), name: 'small', textScale: textScale),
        type: TestDeviceType.smallPhone,
      ),
      TestDevice(device: Device(size: const Size(375, 812), name: 'medium', textScale: textScale)),
      TestDevice(device: Device(size: const Size(412, 730), name: 'wide', textScale: textScale)),
      TestDevice(
        device: Device(size: const Size(1024, 1366), name: 'tablet', textScale: textScale),
        type: TestDeviceType.tablet,
      ),
      ...additionalDevices,
    ];
  }
}
