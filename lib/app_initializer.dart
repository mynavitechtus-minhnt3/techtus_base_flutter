import 'package:flutter/services.dart';

import 'index.dart';

class AppInitializer {
  const AppInitializer._();

  static Future<void> init() async {
    Env.init();
    await configureInjection();
    await getIt.get<PackageHelper>().init();
    await SystemChrome.setPreferredOrientations(
      getIt.get<DeviceHelper>().deviceType == DeviceType.phone
          ? Constant.mobileOrientation
          : Constant.tabletOrientation,
    );
    // Edge to Edge
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
