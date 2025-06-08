import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:nalsflutter/index.dart';

class TestDevice {
  final Device device;
  final TestDeviceType type;

  const TestDevice({
    required this.device,
    this.type = TestDeviceType.phone,
  });
}

enum TestDeviceType {
  smallPhone,
  phone,
  tablet;

  DeviceType get deviceType => switch (this) {
        TestDeviceType.smallPhone => DeviceType.smallPhone,
        TestDeviceType.tablet => DeviceType.tablet,
        _ => DeviceType.phone,
      };
}
