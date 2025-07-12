import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../../index.dart';

final deviceHelperProvider = Provider<DeviceHelper>(
  (ref) => getIt.get<DeviceHelper>(),
);

enum DeviceType { smallPhone, phone, tablet }

@LazySingleton()
class DeviceHelper {
  Future<String> get deviceId async {
    return await FlutterUdid.udid;
  }

  Future<String> get deviceModelName async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

      return iosInfo.name;
    } else {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      return '${androidInfo.brand} ${androidInfo.device}';
    }
  }

  DeviceType get deviceType {
    const _phoneMaxWidth = 550;
    const _smallPhoneMaxWidth = 380;

    final deviceWidth =
        MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first)
            .size
            .shortestSide;
    return deviceWidth < _smallPhoneMaxWidth
        ? DeviceType.smallPhone
        : deviceWidth < _phoneMaxWidth
            ? DeviceType.phone
            : DeviceType.tablet;
  }

  String get operatingSystem => Platform.operatingSystem;
}
