import 'package:flutter/foundation.dart';

import '../../index.dart';

class Config {
  const Config._();

  static const enableGeneralLog = kDebugMode;
  static const isPrettyJson = kDebugMode;
  static const generalLogMode = [LogMode.all];
  static const printStackTrace = kDebugMode;

  /// provider observer
  static const logOnDidAddProvider = false;
  static const logOnDidDisposeProvider = kDebugMode;
  static const logOnDidUpdateProvider = false;
  static const logOnProviderDidFail = kDebugMode;

  /// navigator observer
  static const enableNavigatorObserverLog = kDebugMode;

  /// log interceptor
  static const enableLogInterceptor = kDebugMode;
  static const enableLogRequestInfo = kDebugMode;
  static const enableLogSuccessResponse = kDebugMode;
  static const enableLogErrorResponse = kDebugMode;

  /// device preview
  static const enableDevicePreview = false;
}
